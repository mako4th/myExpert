//+------------------------------------------------------------------+
//|                                          Signal_SpreadFilter.mqh |
//|                                     Copyright 2009-2013, mako4th |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Expert/ExpertSignal.mqh>
#include <Trade/SymbolInfo.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CSignalSpread : public CExpertSignal
  {
protected:
   //--- input parameters
   int               m_maxSpread;

public:
                     CSignalSpread(void);
                    ~CSignalSpread(void);

   //--- methods initialize protected data
   void              maxSpread(int value) { m_maxSpread = value; }

   virtual double    Direction(void);
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSignalSpread::CSignalSpread(void)  : m_maxSpread(50) {}
CSignalSpread::~CSignalSpread(void) {}

//+------------------------------------------------------------------+
//| Check conditions for spread filter.                              |
//+------------------------------------------------------------------+
double CSignalSpread::Direction(void)
  {
   CSymbolInfo info;
   info.Name(Symbol());
   if(info.Spread() > m_maxSpread)
     {
      //--- the "prohibition" signal
      return(EMPTY_VALUE);
     }
   return(0.0);
  }
//+------------------------------------------------------------------+
