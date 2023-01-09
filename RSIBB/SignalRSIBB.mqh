//+------------------------------------------------------------------+
//|                                                            rsibb |
//|                         Copyright 2022, Mako4th@snow.plala.or.jp |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include <Expert/ExpertSignal.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CSignalRSIBB : public CExpertSignal
  {
protected:
   int rsi_period;
   int bands_period;
   
   CiRSI             m_rsi;
   CiBands           m_bands;
   int               m_pattern_0;
   int               m_pattern_1;
   int               m_pattern_2;

public:
                     CSignalRSIBB(void);
                    ~CSignalRSIBB(void);
   void              Pattern_0(int value) {m_pattern_0 = value;}
   void              Pattern_1(int value) {m_pattern_1= value;}
   void              Pattern_2(int value) {m_pattern_2=value;}

   virtual bool      InitIndicators(CIndicators *indicators);
   virtual int       LongCondition(void);
   virtual int       ShortCondition(void);
   
   void set_rsi_period(int value){rsi_period = value;}
   void set_bands_period(int value){bands_period = value;}


protected:
   bool              InitRSIBB(CIndicators *indicators);


  };
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSignalRSIBB::CSignalRSIBB(void):m_pattern_0(90),m_pattern_1(50),m_pattern_2(30)
  {
  }
CSignalRSIBB::~CSignalRSIBB(void) {}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CSignalRSIBB::InitIndicators(CIndicators *indicators)
  {
   if(indicators == NULL)
      return(false);
   if(!CExpertSignal::InitIndicators(indicators))
     {
      return(false);
     }
   if(!InitRSIBB(indicators))
     {
      return(false);
     }
   return(true);

  }
//+------------------------------------------------------------------+
bool CSignalRSIBB::InitRSIBB(CIndicators *indicators)
  {
   if(indicators==NULL)
     {
      return(false);
     }
   if(!indicators.Add(GetPointer(m_rsi)))
     {
      printf(__FUNCTION__+": error adding object m_rsi");
      return(false);
     }
   if(!indicators.Add(GetPointer(m_bands)))
     {
      printf(__FUNCTION__+": error adding object m_bands");
      return(false);
     }
   if(!m_rsi.Create(Symbol(),PERIOD_CURRENT,rsi_period,PRICE_CLOSE))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
   if(!m_bands.Create(Symbol(),PERIOD_CURRENT,bands_period,0,2,m_rsi.Handle()))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
   return(true);
  }

//+------------------------------------------------------------------+
int CSignalRSIBB::LongCondition(void)
  {
   int result = 0;
   int index = StartIndex();
//   if(m_bands.Upper(0) < m_rsi.Main(0)){result = 90;}
//   if(m_bands.base(0) ){}
   if(m_rsi.Main(index) == EMPTY_VALUE)
     {
      printf(__FUNCTION__+": error bands.Lower(0) as EMPTY_VALUE");
     }
   if(m_bands.Lower(index) > m_rsi.Main(index))
     {
      result = 100;
     }
   return(result);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CSignalRSIBB::ShortCondition(void)
  {
   int result = 0;
   int index = StartIndex();
   if(m_bands.Upper(index) < m_rsi.Main(index))
     {
      result = 100;
     }
//   if(m_bands.base(0) ){}

//   if(m_bands.Lower(0) > m_rsi.Main(0))
//     {
//      result = 90;
//     }
   return(result);
  }
//+------------------------------------------------------------------+
