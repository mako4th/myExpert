//+------------------------------------------------------------------+
//|                                              myExpert/common.mqh |
//|                         Copyright 2022, Mako4th@snow.plala.or.jp |
//|                                       https://github.com/mako4th |
//+------------------------------------------------------------------+
enum sigType
  {
   sig_buy,sig_sell,sig_ma,sig_none
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isnewbar()
  {
   static datetime time = 0;
   if(iTime(Symbol(),PERIOD_CURRENT,0) != time)
     {
      time = iTime(Symbol(),PERIOD_CURRENT,0);
      return true;
     }
   return false;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE sigtypeToOrderType(sigType type)
  {
   switch(type)
     {
      case  sig_buy:
         return ORDER_TYPE_BUY;
         break;
      case sig_sell:
         return ORDER_TYPE_SELL;
         break;
      default:
         return ORDER_TYPE;
         break;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LabelInit()
  {
   string objName="sigstate";
   ObjectCreate(0,objName,OBJ_LABEL,0,0,0);

   ObjectSetInteger(0,objName,OBJPROP_XDISTANCE,0);

   ObjectSetInteger(0,objName,OBJPROP_YDISTANCE,0);
   ObjectSetInteger(0,objName,OBJPROP_CORNER,CORNER_RIGHT_LOWER);
   ObjectSetInteger(0,objName,OBJPROP_ANCHOR,ANCHOR_RIGHT_LOWER);
   ObjectSetString(0,objName,OBJPROP_TEXT,"init");
   ObjectSetInteger(0,objName,OBJPROP_FONTSIZE,20);
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LabelUpdate(string text)
  {
   return ObjectSetString(0,"sigstate",OBJPROP_TEXT,"BB(RSI):"+text);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string sigTypeToText(sigType signal)
  {
   string result = "init";
   switch(signal)
     {
      case  sig_buy:
         result="sig_buy";
         break;
      case sig_sell:
         result="sig_sell";
         break;
      case sig_ma:
         result="sig_ma";
         break;
      case sig_none:
         result="sig_none";
         break;
      default:
         result="init";
         break;
     }
   return result;
  }
//+------------------------------------------------------------------+
