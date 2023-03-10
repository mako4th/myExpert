//+------------------------------------------------------------------+
//|                                            RSIBollingerBands.mq5 |
//|                         Copyright 2022, Mako4th@snow.plala.or.jp |
//|                                       https://github.com/mako4th |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Mako4th@snow.plala.or.jp"
#property link      "https://github.com/mako4th"
#property version   "1.00"

#include "../myExpert.mqh"
//+---------------------------------------------------------------------------------+
//|CAccountInfo m_account;
//|FixedLot:固定ロット                                                                |
//|FixedMargin: 余剰証拠金からロット数を計算する。(m_percent %)　　　　                                                                    |
//|     lot=m_account.MaxLotCheck(m_symbol.Name(),ORDER_TYPE_BUY,price,m_percent);  |
//|FiexdRisk: ストップロスが設定されている場合はストップロス損失額が口座残高のm_percent%になるようにロット数を計算する。
//            設定されていない場合は口座の最小ロットで注文される。                                                                     |
//|    lot = MathFloor(m_account.Balance()*m_percent/loss/100.0/stepvol)*stepvol;        |
//|     if(sl==0.0);                                                                |
//|     lot=minvol;                                                                 |
//+---------------------------------------------------------------------------------+
#include <Expert/Money/MoneyFixedLot.mqh>
#include <Expert/Money/MoneyFixedMargin.mqh>
#include <Expert/Money/MoneyFixedRisk.mqh>
#include <Expert\Trailing\TrailingFixedPips.mqh>
#include <Trade/AccountInfo.mqh>
#include <Trade/SymbolInfo.mqh>
#include "mSignalRSIBB.mqh"
#include "../SignalSpreadFilter.mqh"


enum enumMoneyType
  {
   MoneyTypeFixedLot,
   MoneyTypeFixedMargin,
//   MoneyTypeFixedRisk
  };

input int MAGIC = 8844558;
input string EA_Comment = "mrsbb@mako4th";
input double maxSpread = 30.0;
input enumMoneyType MoneyType = MoneyTypeFixedLot;
input double Money_FixLot_Lots    =0.01;
input double Money_Margin_percent = 10;
//input double Money_Risk_percent = 10;

input int RSI_period=8;
input int Bands_period=10;
input int Bands_shift = 0;
input double Signal_StopLevel     =200.0;  // Stop Loss level (in points)
input double Signal_TakeLevel     =200.0;  // Take Profit level (in points)
bool ProcessEvery_tick = false;
input bool UseMultiPattern = false;


//--- inputs for trailing
int    Trailing_FixedPips_StopLevel  =0;           // Stop Loss trailing level (in points)
int    Trailing_FixedPips_ProfitLevel=0;           // Take Profit trailing level (in points)

//input  double            BandsDeviations=2;

int    Signal_ThresholdOpen =10;    // Signal threshold value to open [0...100]
int    Signal_ThresholdClose=10;   // Signal threshold value to close [0...100]
double Signal_PriceLevel    =0.0;   // Price level to execute a deal

int    Signal_Expiration    =4;     // Expiration of pending orders (in bars)

myCExpert ExtExpert;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!ExtExpert.Init(Symbol(),Period(),ProcessEvery_tick,MAGIC))
     {
      printf(__FUNCTION__+": error initializingg expert");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }

   CExpertSignal *signal = new CExpertSignal;
   if(signal==NULL)
     {
      printf(__FUNCTION__+": error creating signal");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }

   ExtExpert.InitSignal(signal);
   signal.ThresholdOpen(Signal_ThresholdOpen);
   signal.ThresholdClose(Signal_ThresholdClose);
   signal.PriceLevel(Signal_PriceLevel);
   signal.StopLevel(Signal_StopLevel);
   signal.TakeLevel(Signal_TakeLevel);
   signal.Expiration(Signal_Expiration);


   CSignalRSIBB *filter0 = new CSignalRSIBB;
   if(filter0==NULL)
     {
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }

   signal.AddFilter(filter0);
   filter0.PeriodRSI(RSI_period);
   filter0.PeriodBands(Bands_period);
   filter0.BandsShift(Bands_shift);
   filter0.UseMultipattern(UseMultiPattern);

   CSignalSpread *filter1 = new CSignalSpread;
   if(filter1==NULL)
     {
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }

   signal.AddFilter(filter1);
   filter1.maxSpread(maxSpread);

   CTrailingFixedPips *trailing=new CTrailingFixedPips;
   if(trailing==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add trailing to expert (will be deleted automatically))
   if(!ExtExpert.InitTrailing(trailing))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set trailing parameters
   trailing.StopLevel(Trailing_FixedPips_StopLevel);
   trailing.ProfitLevel(Trailing_FixedPips_ProfitLevel);

   CMoneyFixedLot *moneyLots=new CMoneyFixedLot;
   CMoneyFixedMargin *moneyMargin=new CMoneyFixedMargin;
   CMoneyFixedRisk *moneyRisk = new CMoneyFixedRisk;
   moneyLots.Lots(0);
   moneyMargin.Percent(0);
   moneyRisk.Percent(0);
   switch(MoneyType)
     {
      case  MoneyTypeFixedLot:
         moneyLots.Lots(Money_FixLot_Lots);
         delete(moneyMargin);
         delete(moneyRisk);
         ExtExpert.InitMoney(moneyLots);
         break;
      case MoneyTypeFixedMargin:
         delete(moneyLots);
         delete(moneyRisk);
         moneyMargin.Percent(Money_Margin_percent);
         ExtExpert.InitMoney(moneyMargin);
         break;
      //case MoneyTypeFixedRisk:
      //   delete(moneyLots);
      //   delete(moneyMargin);
      //   moneyRisk.Percent(Money_Risk_percent);
      //   ExtExpert.InitMoney(moneyRisk);
      //   break;
      default:
         moneyLots.Lots(Money_FixLot_Lots);
         delete(moneyMargin);
         delete(moneyRisk);
         ExtExpert.InitMoney(moneyLots);
         break;
     }


   ExtExpert.setComment(EA_Comment);


//   if(money==NULL)
//     {
//      printf(__FUNCTION__+": error creating money");
//      ExtExpert.Deinit();
//      return(INIT_FAILED);
//     }
//
//   if(!ExtExpert.InitMoney(money))
//     {
//      printf(__FUNCTION__+": error initializing money");
//      ExtExpert.Deinit();
//      return(INIT_FAILED);
//     }

   if(!ExtExpert.ValidationSettings())
     {
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }

   if(!ExtExpert.InitIndicators())
     {
      printf(__FUNCTION__+": error initializing indicators");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
//EventKillTimer();
   ExtExpert.Deinit();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
//CPositionInfo pi;
//int count = 0;
//for(int i=0; i<PositionsTotal(); i++)
//  {
//   pi.SelectByIndex(i);
//   if(pi.Symbol() == Symbol() && pi.Magic() == MAGIC && pi.Profit() > 0)
//     {
//      // ExtExpert.OnTick();
//     }
//  }
//CSymbolInfo info;
//info.Name(_Symbol);
//double spread = info.Spread();
//if(spread <= maxSpread)
//  {
//   ExtExpert.OnTick();
//  }
   ExtExpert.OnTick();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTrade()
  {
   ExtExpert.OnTrade();
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ExtExpert.OnTimer();
  }
//+------------------------------------------------------------------+
