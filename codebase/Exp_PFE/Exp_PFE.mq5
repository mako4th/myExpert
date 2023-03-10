//+------------------------------------------------------------------+
//|                                                      Exp_PFE.mq5 |
//|                               Copyright ｩ 2014, Nikolay Kositsin |
//|                              Khabarovsk,   farria@mail.redcom.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright ｩ 2012, Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property version   "1.00"

#include "TradeAlgorithms.mqh"

#include <SmoothAlgorithms.mqh>
CXMA XMA1;

enum Applied_price_
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4)
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price
   PRICE_DEMARK_         //Demark Price
  };

input double MM=0.1;
input MarginMode MMMode=FREEMARGIN;
input int    StopLoss_=1000;
input int    TakeProfit_=2000;
input int    Deviation_=50;
input bool   BuyPosOpen=true;
input bool   SellPosOpen=true;
input bool   BuyPosClose=true;
input bool   SellPosClose=true;
//+----------------------------------------------+
//| ﾂ蓖鐱 ・・・竟蒻・ PFE             |
//+----------------------------------------------+
input ENUM_TIMEFRAMES InpInd_Timeframe=PERIOD_H4;
//----
input uint PfePeriod=5;
input CXMA::Smooth_Method XMA_Method=CXMA::MODE_JJMA;
input uint XLength=5;
input int XPhase=100;
input Applied_price_ IPC=PRICE_CLOSE_;
input uint SignalBar=1;
//+----------------------------------------------+
//---- ﾎ磅粱褊韃 ・・・・澵顥 蓁 瑙褊・ ・鮏・胙瑶韭・・・淸瑾
int TimeShiftSec;
//---- ﾎ磅粱褊韃 ・・・・澵顥 蓁 淸・・竟蒻・・
int InpInd_Handle;
//---- 髜・粱褊韃 ・・・・澵顥 浯・ ⅳ褪・萵澵顥
int min_rates_total;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- ・・湜・淸・ 竟蒻・ PFE
   InpInd_Handle=iCustom(Symbol(),InpInd_Timeframe,"PFE",PfePeriod,XMA_Method,XLength,XPhase,IPC,0,0,0);
   if(InpInd_Handle==INVALID_HANDLE)
     {
      Print(" ﾍ・琿ⅲ・・・ 淸・竟蒻・ PFE");
      return(INIT_FAILED);
     }

//---- 竟頽鞨・鈞 ・・澵鵫 蓁 瑙褊・ ・鮏・胙瑶韭・・・淸瑾
   TimeShiftSec=PeriodSeconds(InpInd_Timeframe);

//---- ﾈ湜琿韈璋・ ・・澵顥 浯・ ⅳｸ 萵澵顥
   min_rates_total=int(PfePeriod)+1;
   min_rates_total+=GetStartBars(XMA_Method,XLength,XPhase);
   min_rates_total+=int(3+SignalBar);
//--- 鈞粢褊韃 竟頽鞨・鈞・
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   GlobalVariableDel_(Symbol());
   EventKillTimer();
//----
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---- ・魵褞・ ・・籵 矜・浯 蒡瑣ⅸ濵・蓁 ｸ
   if(BarsCalculated(InpInd_Handle)<min_rates_total)
      return;

//---- ・蒹鉤・頌・蓁 濵琿・鵫 碚 渼・IsNewBar() ・SeriesInfoInteger()
   LoadHistory(TimeCurrent()-PeriodSeconds(InpInd_Timeframe)-1,Symbol(),InpInd_Timeframe);

//---- ﾎ磅粱褊韃 ・・・燾・・・澵顥
   double Value[3];
//---- ﾎ磅粱褊韃 瑣顆褥・・・・澵顥
   static bool Recount=true;
   static bool BUY_Open=false,BUY_Close=false;
   static bool SELL_Open=false,SELL_Close=false;
   static datetime UpSignalTime,DnSignalTime;
   static CIsNewBar NB;

//+----------------------------------------------+
//| ﾎ・裝褄褊韃 肬琿魵 蓁 褄鶴              |
//+----------------------------------------------+
   if(!SignalBar || NB.IsNewBar(Symbol(),InpInd_Timeframe) || Recount) // ・魵褞・ 浯 ・粱褊韃 濵粽胛 矜
     {
      //---- 髜炫・・魵鐱 肬琿・
      BUY_Open=false;
      SELL_Open=false;
      BUY_Close=false;
      SELL_Close=false;
      Recount=false;

      //---- ・・褌 粹魵・・粨糲韃・ 萵澵鐱 ・・鞣・
      if(CopyBuffer(InpInd_Handle,0,SignalBar,3,Value)<=0)
        {
         Recount=true;
         return;
        }

      //---- ﾏ鸙韲 肬琿・蓁 ・・・・
      if(Value[1]<Value[2])
        {
         if(BuyPosOpen && Value[0]>Value[1])
            BUY_Open=true;
         if(SellPosClose)
            SELL_Close=true;
         UpSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
        }

      //---- ﾏ鸙韲 肬琿・蓁 ・鮏琥・
      if(Value[1]>Value[2])
        {
         if(SellPosOpen && Value[0]<Value[1])
            SELL_Open=true;
         if(BuyPosClose)
            BUY_Close=true;
         DnSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
        }
     }


   int positionCount = PositionsTotal();

   int count = 0;
   for(int i=0; i<positionCount; i++)
     {
      if(PositionSelect(i))
        {
         if(PositionGetString(POSITION_SYMBOL) == Symbol())
           {
            count++;
           }
        }
     }

   if(count>0)
     {
      BuyPositionClose(BUY_Close,Symbol(),Deviation_);
      SellPositionClose(SELL_Close,Symbol(),Deviation_);
     }
   else
     {
      BuyPositionOpen(BUY_Open,Symbol(),UpSignalTime,MM,MMMode,Deviation_,StopLoss_,TakeProfit_);
      SellPositionOpen(SELL_Open,Symbol(),DnSignalTime,MM,MMMode,Deviation_,StopLoss_,TakeProfit_);
     }

  }
//+------------------------------------------------------------------+
