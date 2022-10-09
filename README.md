# Expert Advisor Boiler Plate

```c
//+------------------------------------------------------------------+
//|                                                 Boiler plate.mq5 |
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

CTrade trade;

ulong buyPos, sellPos;

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
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
//---

}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
//---

}
//+------------------------------------------------------------------+

```
