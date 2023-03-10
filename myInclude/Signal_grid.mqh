//+------------------------------------------------------------------+
//|                                                  Signal_grid.mqh |
//|                                      Copyright 2022, MakotoOkabe |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MakotoOkabe"
#property link      "https://www.mql5.com"
#property version   "1.00"



//openは シグナルを出せるけどcloseは？


//position open
//magic、symbol()で持っているポジションを調べる
//最大ポジション数以内か調べる
//ロット数の上限を調べる
//一番新しいポジションのpriceと現在のpriceを比較する
//take new buyPosition
//latestPrice - PriceCurrent > threshold
//take new sellPosition
//PriceCurrent - latestPrice > threshold

//position close
//管理下のポジションを調べる
//total profitが規定値以上になっていたら管理下の全ポジションをclose
//totalProfit > threshold
//total lossが規定値以上になっていたら管理下の全ポジションclose
//totalLoss < threshold






#include  <Expert/ExpertSignal.mqh>
#include <Trade/PositionInfo.mqh>
#include <Trade/SymbolInfo.mqh>
#include <Trade/Trade.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Signal_grid : public CExpertSignal
  {
private:
   double            gridDistance;
   double            closeProfit;
   int               maxPositions;
public:
                     Signal_grid();
                    ~Signal_grid();

   //
   virtual int       LongCondition(void);
   virtual int       ShortCondition(void);
   virtual bool      CheckCloseLong(double &price);
   virtual bool      CheckCloseSort(double &price);
   void              setgridDistance(double value) {gridDistance = value;}
   void              setCloseProfit(double value) {closeProfit = value;}
   void              setMaxPositions(int value) {maxPositions = value;}

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal_grid::Signal_grid():gridDistance(50),maxPositions(10)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal_grid::~Signal_grid()
  {
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Signal_grid::LongCondition(void)
  {
   CPositionInfo pi;
   CSymbolInfo si;
   si.Name(_Symbol);
   double minPositionPrice = DBL_MAX;
   int positionCount = 0;
   int result = 0;
   si.Refresh();
   si.RefreshRates();
   for(int i=0; i<PositionsTotal(); i++)
     {
      pi.SelectByIndex(i);
      if(pi.Symbol() == _Symbol && pi.Magic() == m_magic && pi.PositionType() == POSITION_TYPE_BUY)
        {
         positionCount++;
         if(pi.PriceOpen() < minPositionPrice)
           {
            minPositionPrice = pi.PriceOpen();
           }
        }
     }
   if(positionCount > 0)
     {
      double ask = si.Ask();
      double p = si.Point();
      double profit = minPositionPrice - ask;
      double profitPoint = profit / si.Point();
     }

   if((minPositionPrice != DBL_MAX && (minPositionPrice - si.Ask()) / si.Point() > gridDistance) && positionCount < 10)
     {
      result = 80;
     }
   printf("positionCount %d",positionCount);
   return(result);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Signal_grid::ShortCondition(void)
  {

   CPositionInfo pi;
   CSymbolInfo si;
   si.Name(_Symbol);

   double maxPositionPrice = -DBL_MAX;
   int positionCount = 0;
   int result = 0;
   for(int i=0; i<PositionsTotal(); i++)
     {
      pi.SelectByIndex(i);
      if(pi.Symbol() == _Symbol && pi.Magic() == m_magic && pi.PositionType() == POSITION_TYPE_SELL)
        {
         positionCount++;
         if(pi.PriceOpen() > maxPositionPrice)
           {
            maxPositionPrice = pi.PriceOpen();
           }
        }
     }

   if((maxPositionPrice != -DBL_MAX && (maxPositionPrice - si.Bid()) /si.Point() > gridDistance) && positionCount < 10)
     {
      result = 80;
     }

   return(result);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Signal_grid::CheckCloseLong(double &price)
  {
   bool result = false;
   CPositionInfo pi;
   CSymbolInfo si;
   double longTotalProfit = 0;
   for(int i=0; i<PositionsTotal(); i++)
     {
      pi.SelectByIndex(i);
      si.Name(_Symbol);
      if(pi.Symbol() == _Symbol && pi.Magic() == m_magic && pi.PositionType() == POSITION_TYPE_BUY)
        {
         longTotalProfit += (pi.PriceCurrent() - pi.PriceOpen()) / si.Point();
        }
     }
   if(longTotalProfit > closeProfit)
     {
      result = true;
     }
   return(result);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Signal_grid::CheckCloseSort(double &price)
  {
   bool result = false;
   CPositionInfo pi;
   CSymbolInfo si;
   double shortTotalProfit = 0;
   for(int i=0; i<PositionsTotal(); i++)
     {
      pi.SelectByIndex(i);
      si.Name(_Symbol);
      if(pi.Symbol() == _Symbol && pi.Magic() == m_magic && pi.PositionType() == POSITION_TYPE_SELL)
        {
         shortTotalProfit += (pi.PriceCurrent() - pi.PriceOpen())/si.Point();
        }
     }
   if(shortTotalProfit > closeProfit)
     {
      result = true;
     }
   return(result);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
