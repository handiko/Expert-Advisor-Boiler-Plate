//+------------------------------------------------------------------+
//|                                     Indicator Based Strategy.mq5 |
//|                                   Copyright 2022, Handiko Gesang |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Handiko Gesang"
#property link      "https://www.mql5.com"
#property version   "1.00"

#define VERSION "1.00"
#define PROJECT_NAME MQLInfoString(MQL_PROGRAM_NAME)

#include <Trade/trade.mqh>

input int Magic = 12345;
input ENUM_TIMEFRAMES Timeframe = PERIOD_CURRENT;

input bool UseTimeFilter = false; // Using Trading Time Filter ?
input string StartTradeTime = "09:00"; // Start of the trading time (hh:mm) broker time
input string StopTradeTime = "14:00";  // Stop of the trading time (hh:mm) broker time

CTrade trade;

ulong buyPos, sellPos;
int totalBars;
bool tradingIsAllowed = true;
string currentTime;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
//---
   trade.SetExpertMagicNumber(Magic);
   if(!trade.SetTypeFillingBySymbol(_Symbol)) {
      trade.SetTypeFilling(ORDER_FILLING_RETURN);
   }
   static bool isInit = false;
   if(!isInit) {
      isInit = true;
      Print(__FUNCTION__, " > EA (re)start...");
      Print(__FUNCTION__, " > EA version ", VERSION, "...");
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         CPositionInfo pos;
         if(pos.SelectByIndex(i)) {
            if(pos.Magic() != Magic) continue;
            if(pos.Symbol() != _Symbol) continue;
            Print(__FUNCTION__, " > Found open position with ticket #", pos.Ticket(), "...");
            if(pos.PositionType() == POSITION_TYPE_BUY) buyPos = pos.Ticket();
            if(pos.PositionType() == POSITION_TYPE_SELL) sellPos = pos.Ticket();
         }
      }
      for(int i = OrdersTotal() - 1; i >= 0; i--) {
         COrderInfo order;
         if(order.SelectByIndex(i)) {
            if(order.Magic() != Magic) continue;
            if(order.Symbol() != _Symbol) continue;
            Print(__FUNCTION__, " > Found pending order with ticket #", order.Ticket(), "...");
            if(order.OrderType() == ORDER_TYPE_BUY_STOP) buyPos = order.Ticket();
            if(order.OrderType() == ORDER_TYPE_SELL_STOP) sellPos = order.Ticket();
         }
      }
   }
//---
   IndicatorInit();

   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
//---
   IndicatorDeInit();
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
//---
   tradingIsAllowed = CheckTradingTime();

   ProcessIndicatorOnTick();

   ProcessPosition(buyPos);
   ProcessPosition(sellPos);

   int bars = iBars(_Symbol, Timeframe);
   if(totalBars != bars) {
      totalBars = bars;

      ProcessIndicatorOnNewBar();

      if(buyPos <= 0) {
         double Signal = BuySignalIsFound();
         if(Signal > 0) {
            if(tradingIsAllowed) {
               ExecuteBuy(Signal);
            }
         }
      } else {
         if(!tradingIsAllowed) {
            DeletePendingOrder(buyPos);
         }
      }

      if(sellPos <= 0) {
         double Signal = SellSignalIsFound();
         if(Signal > 0) {
            if(tradingIsAllowed) {
               ExecuteSell(Signal);
            }
         }
      } else {
         if(!tradingIsAllowed) {
            DeletePendingOrder(sellPos);
         }
      }
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void IndicatorInit() {
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void IndicatorDeInit() {
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ProcessIndicatorOnNewBar() {
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ProcessIndicatorOnTick() {
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckTradingTime() {
   bool IsTradingTime = true;

   datetime time = TimeCurrent();
   currentTime = TimeToString(time, TIME_MINUTES);

   if(UseTimeFilter) {
      if(StringSubstr(currentTime, 0, 5) == StartTradeTime) {
         IsTradingTime = true;
      }
      if(StringSubstr(currentTime, 0, 5) == StopTradeTime) {
         IsTradingTime = false;
      }
   } else {
      IsTradingTime = true;
   }

   return IsTradingTime;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double BuySignalIsFound() {
   double signal = 0;

   return signal;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SellSignalIsFound() {
   double signal = 0;

   return signal;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalcLots(double stopLossPoints) {
   double lots = 0;

   return lots;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ExecuteBuy(double entryPrice) {
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ExecuteSell(double entryPrice) {
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeletePendingOrder(ulong & posTicket) {
   trade.OrderDelete(posTicket);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ProcessPosition(ulong &posTicket) {
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  OnTradeTransaction(
   const MqlTradeTransaction &    trans,
   const MqlTradeRequest &        request,
   const MqlTradeResult &         result
) {
   if(trans.type == TRADE_TRANSACTION_ORDER_ADD) {
      COrderInfo order;
      if(order.Select(trans.order)) {
         if(order.Magic() == Magic) {
            if(order.OrderType() == ORDER_TYPE_BUY_STOP) {
               buyPos = order.Ticket();
            } else if(order.OrderType() == ORDER_TYPE_SELL_STOP) {
               sellPos = order.Ticket();
            }
         }
      }
   }
}
//+------------------------------------------------------------------+
