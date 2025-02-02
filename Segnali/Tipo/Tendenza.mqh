//+------------------------------------------------------------------+
//|                                                     Tendenza.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include <FQInclude\Segnali\SegnaliMain.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTendenza : public CSegnaliMain
  {

public:

   string            Media(int shift,string symbol, ENUM_TIMEFRAMES period, int ma_period, int ma_shift, ENUM_MA_METHOD ma_method, int applied);
   string            Tendenza(int CandeleTotali, string simbolo, ENUM_TIMEFRAMES period);  
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CTendenza::Media(int shift,string symbol, ENUM_TIMEFRAMES period, int ma_period, int ma_shift, ENUM_MA_METHOD ma_method, int applied)
  {
   double Low = iLow(symbol, period, shift);
   double High = iHigh(symbol, period, shift);
   double Close = iClose(symbol,period,shift);
   double Open = iOpen(symbol,period,shift);

   CiMA *OBMA = CreateMovingAverage(symbol,period,ma_period,ma_shift,ma_method,applied,shift);

   if(OBMA.Main(shift) != OBMA.Main(shift+1))
     {
      if(OBMA.Main(shift) < Low)
         return "rialzista";
      if(OBMA.Main(shift) > High)
         return "ribassista";
     }
   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CTendenza::Tendenza(int CandeleTotali, string simbolo, ENUM_TIMEFRAMES period)
  {
   string TendenzaRitorno = "";
   int massimi = 0;
   int minimi = 0;
   double prezzo_massimo = 0.0;
   double prezzo_minimo = DBL_MAX; // Modificato per inizializzare al valore massimo possibile per un double
   double High = 0.0;
   double Low = 0.0;

   for(int i = CandeleTotali; i > 0; i--)
     {
      High = iHigh(simbolo, period, i);
      Low = iLow(simbolo, period, i);

      if(High > prezzo_massimo)
        {
         prezzo_massimo = High;
         massimi++;
        }

      if(Low < prezzo_minimo)
        {
         prezzo_minimo = Low;
         minimi++;
        }
     }

   if(massimi > minimi)
      TendenzaRitorno = "rialzista";
   else
      if(minimi > massimi)
         TendenzaRitorno = "ribassista";
      else
         TendenzaRitorno = "laterale"; // aggiunto per gestire il caso di parità

   return TendenzaRitorno;
  }
//+------------------------------------------------------------------+
