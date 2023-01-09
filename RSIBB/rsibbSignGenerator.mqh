//+------------------------------------------------------------------+
//|                                                            rsibb |
//|                         Copyright 2022, Mako4th@snow.plala.or.jp |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Mako4th@snow.plala.or.jp"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Expert/ExpertSignal.mqh>

#include "mySignalState.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class rsibbSignGenerator
  {
public:
                     rsibbSignGenerator(void) {};
                    ~rsibbSignGenerator(void) {};
   void              init(int inRSI_Period,int inBands_Period,double inBandsDeviations,double inSensitivity);
   sigType              update();
private:
   int               RSI_Handle;
   int               RSI_Period;
   int               Bands_Handle;
   int               Bands_Period;
   double            BandsDeviations;
   double            Sensitivity;
   mySignalState     signalState;
  };
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void rsibbSignGenerator::init(int inRSI_Period,int inBands_Period,double inBandsDeviations,double inSensitivity)
  {
   RSI_Period = inRSI_Period;
   Bands_Period = inBands_Period;
   BandsDeviations = inBandsDeviations;
   Sensitivity = inSensitivity;
   CIndicators cis;
   RSI_Handle = iRSI(_Symbol,_Period,RSI_period,PRICE_CLOSE);
   Bands_Handle = iBands(_Symbol,_Period,Bands_Period,0,BandsDeviations,RSI_Handle);

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
sigType rsibbSignGenerator::update(void)
  {
//BollingerBand Buffer Index 0:ma 1:upper 2:lower
   double rsi[1],ma[1],ub[1],lb[1];
   CopyBuffer(RSI_Handle,0,0,1,rsi);
   CopyBuffer(Bands_Handle,0,0,1,ma); //ma
   CopyBuffer(Bands_Handle,1,0,1,ub); //upper
   CopyBuffer(Bands_Handle,2,0,1,lb); //lower
//SetIndexBuffer(0,sigSellBuff,INDICATOR_DATA);
//SetIndexBuffer(1,sigBuyBuff,INDICATOR_DATA);
//PlotIndexSetInteger(0,PLOT_ARROW,242);
//PlotIndexSetInteger(1,PLOT_ARROW,241);
   sigType result = sig_none;
   if((lb[0]+ma[0])/2 < rsi[0] && (ub[0]+ma[0])/2 > rsi[0])//  MathAbs(rsi[0]-ma[0]) < Sensitivity)
     {
      result = sig_ma;
     }
   else
      if(rsi[0] > ub[0])
        {
         result = sig_sell;
        }
      else
         if(rsi[0] < lb[0])
           {
            result = sig_buy;
           }
 
   signalState.setSignal(result);
   Sleep(10);
   result = signalState.getSignal();
   //ObjectSetString(0,"sigstate",OBJPROP_TEXT,"BB(RSI) " + signalToText(result));
   return result;
  }
//+------------------------------------------------------------------+
