//+------------------------------------------------------------------+
//|                                                   debugLabel.mqh |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link "https://www.mql5.com"
#property version "1.00"

#include "common.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class debugLabel
{
private:
public:
  debugLabel();
  ~debugLabel();
  void updateLabel(string outputText);
  string signalToText(sigType signal);

  string objectName = "debugLabel";
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
debugLabel::debugLabel()
{
  ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0);
  ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, 0);
  ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, 0);
  ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_RIGHT_LOWER);
  ObjectSetInteger(0, objName, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
  ObjectSetString(0, objName, OBJPROP_TEXT, "init");
  ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 20);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
debugLabel::~debugLabel()
{
}
//+------------------------------------------------------------------+
string debugLabel::signalToText(sigType sig)
{
  string result = "init";
  switch (sig)
  {
  case sig_buy:
    result = "sig_buy";
    break;
  case sig_sell:
    result = "sig_sell";
    break;
  case sig_ma:
    result = "sig_ma";
    break;
  case sig_none:
    result = "sig_none";
    break;
  default:
    result = "init";
    break;
  }
  return result;
}
//+------------------------------------------------------------------+

void debugLabel::updateLabel(string outputText)
{
  ObjectSetString(0, objectName, OBJPROP_TEXT, "BB(RSI) " + outputText);
}