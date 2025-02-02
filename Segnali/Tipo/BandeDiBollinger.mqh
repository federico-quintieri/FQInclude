//+------------------------------------------------------------------+
//|                                             BandeDiBollinger.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include <FQInclude\Segnali\SegnaliMain.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CBandeDiBollinger : public CSegnaliMain
  {

public:
   string            ToccoBanda(int shift, string symbol, ENUM_TIMEFRAMES period, int ma_period, int ma_shift, double deviation, int applied);
   string            DivergenzaBande(string symbol, ENUM_TIMEFRAMES period, int ma_period, int ma_shift, double deviation, int applied);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CBandeDiBollinger::ToccoBanda(int shift, string symbol, ENUM_TIMEFRAMES period, int ma_period, int ma_shift, double deviation, int applied)
  {
   double Low = iLow(symbol, period, shift);
   double High = iHigh(symbol, period, shift);
   double Close = iClose(symbol,period,shift);
   double Open = iOpen(symbol,period,shift);

   CiBands *OBBande = CreateBandsIndicator(symbol, period, ma_period, ma_shift, deviation, applied, shift);

   if(OBBande.Upper(shift) != OBBande.Lower(shift))
     {

      double bandaupper = NormalizeDouble(OBBande.Upper(shift),Digits());
      double bandalower = NormalizeDouble(OBBande.Lower(shift),Digits());

      if(Low < bandalower && Close > bandalower && Open > bandalower)
        {
         DeleteBandsIndicator(OBBande);
         return "rialzista";
        }
      if(High > bandaupper && Close < bandaupper && Open < bandaupper)
        {
         DeleteBandsIndicator(OBBande);
         return "ribassista";
        }
     }

   DeleteBandsIndicator(OBBande);
   return "";
  }
//+------------------------------------------------------------------+
string CBandeDiBollinger::DivergenzaBande(string symbol, ENUM_TIMEFRAMES period, int ma_period, int ma_shift, double deviation, int applied)
  {

   CiBands *OBBande = CreateBandsIndicator(symbol, period, ma_period, ma_shift, deviation, applied, 5);

   if(OBBande.Upper(1) != OBBande.Lower(2))
     {
      if(OBBande.Upper(1) < OBBande.Upper(2))
        {
         DeleteBandsIndicator(OBBande);
         return "UpperBandAbbassata";
        }
      if(OBBande.Lower(1) > OBBande.Lower(2))
        {
         DeleteBandsIndicator(OBBande);
         return "LowerBandAlzata";
        }
     }
   DeleteBandsIndicator(OBBande);
   return "";
  }
//+------------------------------------------------------------------+
