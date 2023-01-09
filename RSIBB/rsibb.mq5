//+------------------------------------------------------------------+
//|                                            RSIBollingerBands.mq5 |
//|                         Copyright 2022, Mako4th@snow.plala.or.jp |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Mako4th@snow.plala.or.jp"
#property link      "https://www.mql5.com"
#property version   "1.00"
//#include <Trade/Trade.mqh>
//#include <Trade/AccountInfo.mqh>
#include <Expert/Expert.mqh>
#include <Expert/Money/MoneyFixedLot.mqh>
#include <Expert/Money/MoneyFixedMargin.mqh>
#include "SignalRSIBB.mqh"

input   int               RSI_period=8;
input   int               Bands_period=24;
//input double Money_FixLot_Lots    =0.01;   // Fixed volume
input double Moey_FixMargin_percent = 10;
//input  double            BandsDeviations=2;

input int MAGIC = 8844558;


input int    Signal_ThresholdOpen =80;    // Signal threshold value to open [0...100]
input int    Signal_ThresholdClose=80;    // Signal threshold value to close [0...100]
input double Signal_PriceLevel    =0.0;   // Price level to execute a deal
input double Signal_StopLevel     =200.0;  // Stop Loss level (in points)
input double Signal_TakeLevel     =200.0;  // Take Profit level (in points)
input int    Signal_Expiration    =4;     // Expiration of pending orders (in bars)
//--- inputs for money
//input double Money_FixLot_Percent =10.0;  // Percent


CExpert ExtExpert;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
//   EventSetTimer(60*5);
   if(!ExtExpert.Init(Symbol(),Period(),false,88788))
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
   filter0.set_rsi_period(RSI_period);
   filter0.set_bands_period(Bands_period);
   filter0.Weight(1);
   

   //CMoneyFixedLot *money=new CMoneyFixedLot;
      CMoneyFixedMargin *money=new CMoneyFixedMargin;
   if(money==NULL)
     {
      printf(__FUNCTION__+": error creating money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }

   if(!ExtExpert.InitMoney(money))
     {
      printf(__FUNCTION__+": error initializing money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }

   //money.Lots(Money_FixLot_Lots);
   money.Percent(Moey_FixMargin_percent);

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
void OnTick()
  {
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