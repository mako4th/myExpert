//+------------------------------------------------------------------+
//|                                                    envelopes.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include "myInclude/myExpert.mqh"
#include "myInclude/Signal_grid.mqh"
#include "myInclude/SignalSpreadFilter.mqh"

//--- available signals
#include <Expert\Signal\SignalEnvelopes.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingParabolicSAR.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedLot.mqh>
#include <Expert/Money/MoneyFixedMargin.mqh>

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert

string Expert_Title ="envelopes";
sinput string RecommendTimeFrame="M15";
input ulong Expert_MagicNumber =21676;
input string EA_Comment = "EA_Envelopes@mako4th";
input int maxSpread = 30;

bool                     Expert_EveryTick             =false;
//--- inputs for main signal
int                Signal_ThresholdOpen         =30;          // Signal threshold value to open [0...100]
int                Signal_ThresholdClose        =30;          // Signal threshold value to close [0...100]
double             Signal_PriceLevel            =0.0;         // Price level to execute a deal
input double             Signal_StopLevel             =100.0;        // Stop Loss level (in points)
input double             Signal_TakeLevel             =100;        // Take Profit level (in points)
int                Signal_Expiration            =1;           // Expiration of pending orders (in bars)
input int                PeriodMA_Envelopes    =8;          // Envelopes(45,0,MODE_SMA,...) Period of averaging
input int                Shift_Envelopes       =0;           // Envelopes(45,0,MODE_SMA,...) Time shift
ENUM_MA_METHOD     Signal_Envelopes_Method      =MODE_SMA;    // Envelopes(45,0,MODE_SMA,...) Method of averaging
ENUM_APPLIED_PRICE Signal_Envelopes_Applied     =PRICE_CLOSE; // Envelopes(45,0,MODE_SMA,...) Prices series
input double             Deviation_Envelopes   =0.1;//0.25;        // Envelopes(45,0,MODE_SMA,...) Deviation
double             Weight_Envelopes      =1.0;         // Envelopes(45,0,MODE_SMA,...) Weight [0...1.0]
//--- inputs for trailing
//input double             Trailing_ParabolicSAR_Step   =0.02;
//input double             Trailing_ParabolicSAR_Maximum=0.2;
//--- inputs for money
input group "MoneyType"
double             Money_Margin_Percent         =10.0;
input double             Money_FixLot_Lots            =0.1;


//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+
myCExpert ExtExpert;
//+------------------------------------------------------------------+
//| Initialization function of the expert                            |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Initializing expert
   if(!ExtExpert.Init(Symbol(),Period(),Expert_EveryTick,Expert_MagicNumber))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing expert");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Creating signal
   CExpertSignal *signal=new CExpertSignal;
   if(signal==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating signal");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//---
   ExtExpert.InitSignal(signal);
   signal.ThresholdOpen(Signal_ThresholdOpen);
   signal.ThresholdClose(Signal_ThresholdClose);
   signal.PriceLevel(Signal_PriceLevel);
   signal.StopLevel(Signal_StopLevel);
   signal.TakeLevel(Signal_TakeLevel);
   signal.Expiration(Signal_Expiration);
//--- Creating filter CSignalEnvelopes
   CSignalEnvelopes *filter0=new CSignalEnvelopes;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.PeriodMA(PeriodMA_Envelopes);
   filter0.Shift(Shift_Envelopes);
   filter0.Method(Signal_Envelopes_Method);
   filter0.Applied(Signal_Envelopes_Applied);
   filter0.Deviation(Deviation_Envelopes);
   filter0.Weight(Weight_Envelopes);

   CSignalSpread *filter1 = new CSignalSpread;
   if(filter1==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter1);
   filter1.maxSpread(maxSpread);

//   Signal_grid *filter2=new Signal_grid;
//  signal.AddFilter(filter2);
//   filter2.setgridDistance(50);
//   filter2.setCloseProfit(30);
//   filter2.setMaxPositions(10);

//--- Creation of trailing object
//   CTrailingPSAR *trailing=new CTrailingPSAR;
//   if(trailing==NULL)
//     {
//      //--- failed
//      printf(__FUNCTION__+": error creating trailing");
//      ExtExpert.Deinit();
//      return(INIT_FAILED);
//     }
////--- Add trailing to expert (will be deleted automatically))
//   if(!ExtExpert.InitTrailing(trailing))
//     {
//      //--- failed
//      printf(__FUNCTION__+": error initializing trailing");
//      ExtExpert.Deinit();
//      return(INIT_FAILED);
//     }
////--- Set trailing parameters
//   trailing.Step(Trailing_ParabolicSAR_Step);
//   trailing.Maximum(Trailing_ParabolicSAR_Maximum);
//--- Creation of money object

   CMoneyFixedLot *money=new CMoneyFixedLot;
//CMoneyFixedMargin *money = new CMoneyFixedMargin;
   if(money==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add money to expert (will be deleted automatically))
   if(!ExtExpert.InitMoney(money))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }

//--- Set money parameters
//money.Percent(Money_Margin_Percent);//Money_FixLot_Percent);
   money.Lots(Money_FixLot_Lots);

//--- Check all trading objects parameters
   if(!ExtExpert.ValidationSettings())
     {
      //--- failed
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Tuning of all necessary indicators
   if(!ExtExpert.InitIndicators())
     {
      //--- failed
      printf(__FUNCTION__+": error initializing indicators");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }

   ExtExpert.setComment(EA_Comment);

//--- ok
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ExtExpert.Deinit();
  }
//+------------------------------------------------------------------+
//| "Tick" event handler function                                    |
//+------------------------------------------------------------------+
void OnTick()
  {
   ExtExpert.OnTick();
  }
//+------------------------------------------------------------------+
//| "Trade" event handler function                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
   ExtExpert.OnTrade();
  }
//+------------------------------------------------------------------+
//| "Timer" event handler function                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ExtExpert.OnTimer();
  }
//+------------------------------------------------------------------+
