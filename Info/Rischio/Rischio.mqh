//+------------------------------------------------------------------+
//|                                                      Rischio.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include <FQInclude\Info\Info.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CRischio:public CInfo
  {
private:
   double            Balance_iniziale;
   double            Lottaggio;
   double            TickReale();
   double            CalcolaLottaggio(double riskMoney, double range_stop);
   double            BidSimbolo(string Simbolo_Forex);
   
public:
                     CRischio()
     {
      Balance_iniziale = AccountInfoDouble(ACCOUNT_BALANCE);
      Lottaggio = 0.0;
     }

                    ~CRischio() {}

   double            Compounding(double Lotti_Iniziali);
   double            RischioinDenaro(double denaro, double range_stop);
   double            RischioinPercentuale(double percentuale, double range_stop);
   double            CalcoloLottiKellyFormula(double Probablita_Successo, double Rischio_Rendimento, double grandezza_stop);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CRischio::Compounding(double Lotti_Iniziali)
  {
   double Coefficiente = AccountInfoDouble(ACCOUNT_BALANCE) / Balance_iniziale;
   Lottaggio = Lotti_Iniziali * Coefficiente;
   return NormalizeDouble(Lottaggio, 2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CRischio::RischioinDenaro(double denaro, double range_stop)
  {
   double riskMoney = denaro;
   return CalcolaLottaggio(riskMoney, range_stop);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CRischio::RischioinPercentuale(double percentuale, double range_stop)
  {
   double riskMoney = AccountInfoDouble(ACCOUNT_BALANCE) * percentuale / 100;
   return CalcolaLottaggio(riskMoney, range_stop);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CRischio::CalcolaLottaggio(double riskMoney, double range_stop)
  {
   double ticksize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double tickvalue = TickReale();
   double lotstep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   if(ticksize == 0 || tickvalue == 0 || lotstep == 0)
     {
      Print(__FUNCTION__, " > Il lottaggio non può essere calcolato");
      return 0;
     }

   double moneyLotStep = (range_stop / ticksize) * tickvalue * lotstep;

   if(moneyLotStep == 0)
     {
      Print(__FUNCTION__, " > Il lottaggio non può essere calcolato");
      return 0;
     }

   double Lots = MathFloor(riskMoney / moneyLotStep) * lotstep;

   return Lots;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CRischio::BidSimbolo(string Simbolo_Forex)
  {
   bool simbolo_custom = false;
   double bid = 1;

   if(SymbolExist(Simbolo_Forex, simbolo_custom))
     {
      bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
     }

   string ForexSymbolInvertito = StringSubstr(Simbolo_Forex, 3, 3) + StringSubstr(Simbolo_Forex, 0, 3) + StringSubstr(Simbolo_Forex, 6);

   if(SymbolExist(ForexSymbolInvertito, simbolo_custom))
     {
      bid = 1 / SymbolInfoDouble(ForexSymbolInvertito, SYMBOL_BID);
     }

   return bid;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CRischio::TickReale()
  {
   double calcolo = 1;

   ENUM_SYMBOL_CALC_MODE modalitacalcolo = (ENUM_SYMBOL_CALC_MODE)SymbolInfoInteger(Symbol(), SYMBOL_TRADE_CALC_MODE);
   string currencymargin = SymbolInfoString(Symbol(), SYMBOL_CURRENCY_MARGIN);
   string valutaaccount = AccountInfoString(ACCOUNT_CURRENCY);

   if(modalitacalcolo == SYMBOL_CALC_MODE_FUTURES || modalitacalcolo == SYMBOL_CALC_MODE_CFDINDEX)
     {
      calcolo = calcolo * BidSimbolo(currencymargin + valutaaccount);
     }

   double valoretickreale = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_VALUE) * calcolo;

   return valoretickreale;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CRischio::CalcoloLottiKellyFormula(double Probablita_Successo, double Rischio_Rendimento, double grandezza_stop)
  {
   double lotti_da_investire = 0.0;

   Probablita_Successo = Probablita_Successo / 100.0;

   double Percentuale_da_rischiare = 0;

   if(Rischio_Rendimento >= 1)
     {
      Percentuale_da_rischiare = Probablita_Successo - ((1 - Probablita_Successo) / Rischio_Rendimento);
     }
   else
     {
      Percentuale_da_rischiare = (Probablita_Successo * (Rischio_Rendimento + 1)) - 1;
     }

   Percentuale_da_rischiare = NormalizeDouble(Percentuale_da_rischiare * 100, 2);

   lotti_da_investire = NormalizeDouble(CalcolaLottaggio(Percentuale_da_rischiare, grandezza_stop), 2);

// Mi ritorno un 30% del valore reale
   return  NormalizeDouble(lotti_da_investire * 0.3, 2);
  }
//+------------------------------------------------------------------+
