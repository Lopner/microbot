input double lots=0.5;        // объем в лотах
input ulong  EXPERT_MAGIC=0;  // MagicNumber эксперта
input int    slippage=10;     // допустимое проскальзывание

double trade_lot;
int movdef1,movdef2;
bool buy, sell;

//==================
input int StopLoss=30;
input int TakeProfit=100;
input int MA_Period=8;
//==================


int OnInit()
  {
   buy = true;
   sell = true;
   //--- установим правильный объем
   double min_lot=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   trade_lot=lots>min_lot? lots:min_lot; 
   //iMA - индикатора скользящего среднего (1.период,2. период усреднения,3.смещение индикатора по горизонтали,4. тип сглаживания,5. тип цены или handle)
   movdef1 = iMA(_Symbol, _Period, 20,0, MODE_EMA, PRICE_CLOSE);
   //--- если не удалось создать хэндл 
   if(movdef1==INVALID_HANDLE) 
   { 
   //--- работа индикатора завершается досрочно 
   Comment("ERROR INIT"); 
   } 
   
   movdef2 = iMA(_Symbol, _Period, 50,0, MODE_EMA, PRICE_CLOSE);
   //--- если не удалось создать хэндл 
   if(movdef2==INVALID_HANDLE) 
   { 
   //--- работа индикатора завершается досрочно 
    Comment("ERROR INIT");  
   }        
   
   
   
 //--- успешная инициализация эксперта
   return(INIT_SUCCEEDED);  
}


//============================
void OnDeinit (const int reason)
{
}
//============================


void OnTick()
  {
  
      double MymovAverage[], MymovAverage2[];
     
      //перварачиваем массив - первый элемент, самый новый
      ArraySetAsSeries(MymovAverage, true);
      ArraySetAsSeries(MymovAverage2, true);  
      
      CopyBuffer(movdef1, 0,0,3, MymovAverage);    
      CopyBuffer(movdef2, 0,0,3, MymovAverage2);    
      
      if (buy && (MymovAverage[0]>MymovAverage2[0]) && (MymovAverage[1]<MymovAverage2[1]) )
      {
         Comment("byu");
         Buy(trade_lot,slippage,EXPERT_MAGIC);
         buy = false;
         sell = true;
      }
     
      if (sell && (MymovAverage[0]<MymovAverage2[0]) && (MymovAverage[1]>MymovAverage2[1]) )
      {
         Comment("sell");
         Sell(trade_lot,slippage,EXPERT_MAGIC);
         sell = false;
         buy = true;
      }     
      
             
  }


//+------------------------------------------------------------------+
//| Покупка по рынку с заданным объемом                              |
//+------------------------------------------------------------------+
bool Buy(double volume,ulong deviation=10,ulong  magicnumber=0)
  {
//--- покупаем по рыночной цене
   return (MarketOrder(ORDER_TYPE_BUY,volume,deviation,magicnumber));
  }
//+------------------------------------------------------------------+
//| Продажа по рынку с заданным объемом                              |
//+------------------------------------------------------------------+
bool Sell(double volume,ulong deviation=10,ulong  magicnumber=0)
  {
//--- продаем по рыночной цене
   return (MarketOrder(ORDER_TYPE_SELL,volume,deviation,magicnumber));
  }

//+------------------------------------------------------------------+
//| Подготовка и отправка торгового запроса                          |
//+------------------------------------------------------------------+
bool MarketOrder(ENUM_ORDER_TYPE type,double volume,ulong slip,ulong magicnumber,ulong pos_ticket=0)
  {
//--- объявление и инициализация cтруктур
   MqlTradeRequest request={0};
   MqlTradeResult  result={0};
   double price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   if(type==ORDER_TYPE_BUY)
      price=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
//--- параметры запроса
   request.action   =TRADE_ACTION_DEAL;                     // тип торговой операции
   request.position =pos_ticket;                            // тикет позиции, если закрываем
   request.symbol   =Symbol();                              // символ
   request.volume   =volume;                                // объем 
   request.type     =type;                                  // тип ордера
   request.price    =price;                                 // цена совершения сделки
   request.deviation=slip;                                  // допустимое отклонение от цены
   request.magic    =magicnumber;                           // MagicNumber ордера
//--- отправка запроса
   if(!OrderSend(request,result))
     {
      //--- выведем информацию о неудаче
      PrintFormat("OrderSend %s %s %.2f at %.5f error %d",
                  request.symbol,EnumToString(type),volume,request.price,GetLastError());
      return (false);
     }
//--- сообщим об успешной операции
   PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
   return (true);
  }
  
  
  
  
 // MymovAverage[0]
 // MymovAverage[1]
  
  //MymovAverage2[0]
  //MymovAverage2[1]
