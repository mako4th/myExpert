//+------------------------------------------------------------------+
//|                                                            rsibb |
//|                         Copyright 2022, Mako4th@snow.plala.or.jp |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Mako4th@snow.plala.or.jp"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade/Trade.mqh>
#include "rsibbSignal.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class positionControl
  {
private:
   void              positionOpen(ENUM_ORDER_TYPE type,double volume,long MAGIC,string comment);

public:
                     positionControl(void) {};
                    ~positionControl(void) {};
   int               magicCount(long);
   void              positionCheck(double volume,long Magic,string comment);
  };
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int positionControl::magicCount(long magicNumber)
  {
   CPositionInfo pi;
   int count = 0;
   for(int i=0; i<PositionsTotal(); i++)
     {
      pi.SelectByIndex(i);
      if(pi.Symbol() == Symbol() && pi.Magic() == magicNumber)
        {
         count++;
        }
     }
   return count;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void positionControl::positionOpen(ENUM_ORDER_TYPE type,double volume,long MAGIC,string comment)
  {
   CTrade ct;
   double price = SymbolInfoDouble(_Symbol,type==ORDER_TYPE_BUY ? SYMBOL_ASK:SYMBOL_BID);
   double slRetio = 0.0005;
   double tpRetio = 0.001;
   double sl = 0;// = type==ORDER_TYPE_BUY ? price * (1 - slRetio):price *(1+slRetio);
   double tp = 0; // type==ORDER_TYPE_BUY ? price * (1+tpRetio):price * (1-tpRetio);
   ct.SetExpertMagicNumber(MAGIC);
   ct.PositionOpen(_Symbol,type,volume,price,sl,tp,comment+IntegerToString(MAGIC));
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void positionControl::positionCheck(double volume,long MAGIC,string comment)
  {
   CPositionInfo pInfo;
   rsibb rb;
   CTrade ct;
   signalInfo si = rb.getSigInfo();
   if(magicCount(MAGIC) < 1)
     {
      if(si.sig == sig_buy)
        {

         positionOpen(ORDER_TYPE_BUY,volume,MAGIC,comment);

        }
      if(si.sig == sig_sell)
        {
         positionOpen(ORDER_TYPE_SELL,volume,MAGIC,comment);
        }

     }
   else
     {
      for(int i=0; i<PositionsTotal(); i++)
        {
         pInfo.SelectByIndex(i);
         if(pInfo.Symbol() == Symbol() && pInfo.Magic() == MAGIC)
           {
            if(pInfo.PositionType() == POSITION_TYPE_BUY && si.sig==sig_sell)
              {
               ct.PositionClose(pInfo.Ticket(),10);
              }
            if(pInfo.PositionType() == POSITION_TYPE_SELL && si.sig==sig_buy)
              {
               ct.PositionClose(pInfo.Ticket(),10);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
