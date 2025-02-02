//+------------------------------------------------------------------+
//|                                              PatternDiPrezzo.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include <FQInclude\Segnali\SegnaliMain.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CPatternDiPrezzo: public CSegnaliMain
  {
public:

   string              Engulfing(string Simbolo, ENUM_TIMEFRAMES Periodo);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CPatternDiPrezzo::Engulfing(string Simbolo, ENUM_TIMEFRAMES Periodo)
  {
   double Close_1 = iClose(Simbolo,Periodo,1);
   double Open_1 = iOpen(Simbolo,Periodo,1);

   double Close_2 = iClose(Simbolo,Periodo,2);
   double Open_2 = iOpen(Simbolo,Periodo,2);

// Verifica se la candela precedente è ribassista e la candela attuale è rialzista
   if(Close_2 < Open_2 && Close_1 > Open_1)
     {
      double body_rossa = MathAbs(Close_2 - Open_2); // Lunghezza del corpo della candela precedente
      double body_verde = MathAbs(Close_1 - Open_1); // Lunghezza del corpo della candela attuale

      // Verifica se il corpo della candela attuale inghiotte completamente il corpo della candela precedente
      if(Close_1 > Open_2 && body_verde >= (body_rossa*2))
        {
         return "rialzista"; // Bullish Engulfing pattern rilevato
        }
     }

// La candela 2 è rialzista e la precedente è ribassista
   if(Close_2 > Open_2 && Close_1 < Open_1)
     {
      double body_verde = MathAbs(Close_2-Open_2); // Body candela verde
      double body_rossa = MathAbs(Open_1-Close_1); // Body candela rossa

      // Verifica se il corpo della candela precedente inghiotte completamente il corpo della candela 2
      if(Close_1 < Open_2 && body_rossa >= (body_verde*2))
        {
         return "ribassista";
        }
     }

   return "";
  }
//+------------------------------------------------------------------+
