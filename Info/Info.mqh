//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

struct DealInfo
  {
   ulong             ticket;
   string            symbol;
   ENUM_DEAL_ENTRY   tipo_entrata;
   ENUM_DEAL_TYPE    tipo_deal;
   datetime          time;
   long              magic;
   double            volume;
   double            price;
   double            profit;
   double            fee;
   double            commission;
   double            swap;
   double            take;
   double            stop;
  };

struct PositionInfo
  {
   ulong              ticket;
   string             symbol;
   datetime           time;
   ENUM_POSITION_TYPE tipo;
   long               magic;
   double             volume;
   double             price_open;
   double             stop;
   double             take;
   double             swap;
   double             profit;
  };

struct OrderInfo
  {
   ulong             ticket;
   string            symbol;
   datetime          time_inserimento;
   datetime          time_cancellazione;
   ENUM_ORDER_TYPE   tipo;
   long              magic;
   double            volume;
   double            stop;
   double            take;
  };

// Andiamo a creare una classe di nome CInfo
class CInfo
  {
   //Facciamo delle variabili per i nostri calcoli dentro le funzioni
private:
   int               BarsCount;
   double            pips;

public:
   //Inizializziamo queste variabili nel costruttore
                     CInfo(void)
     {
      this.BarsCount=0;
      this.pips = 0.0 ;
     };
                    ~CInfo(void) {};

   // Da qui vado a fare tutte le funzioni (Metodi) della mia classe con i vari parametri di ingresso
   bool              NuovaCandela();
   double            Pips();
   bool              CiSonoPosizioni(int magic, string symbol,ENUM_POSITION_TYPE tipoposizione);
   bool              CiSonoOrdini(int magico, string simbolo,ENUM_ORDER_TYPE tipoordine);
   DealInfo          InfoUltimoDeal(string Mercato, int Magico);
   PositionInfo      InfoUltimaPosizione(string Mercato, int Magico);
   OrderInfo         InfoUltimoOrdine(string Mercato, int Magico);
   datetime          StartOfToday();
   datetime          EndOfToday();
   double            RisultatoDealsGiornalieri(int magic, string simbolo);
   double            RisultatoPosizioniAperte(int magic, string simbolo);
   double            RisultatoGiornaliero(int magic, string simbolo);
   bool              PassateBarreDaPerdita(int magic, string simbolo,ENUM_TIMEFRAMES periodo, int candele);
   bool              PassateTotCandele(int candele,string simbolo, ENUM_TIMEFRAMES periodo, datetime orario);
   double            Massimo(int candele_totali, int candela_inizio);
   double            Minimo(int candele_totali, int candela_inizio);
   double            Ask();
   double            Bid();
   MqlDateTime       Tempo();
   bool              IsInTimeRange(datetime datainiziale, datetime datafinale);

  };
//Funzione che ritorna true se c'è un nuova candela sul grafico
bool CInfo::NuovaCandela()
  {
// Se il numero di barre è maggiore alla variabile Barscount(all'inzio vale 0)
   if(Bars(Symbol(),PERIOD_CURRENT) > BarsCount)
     {
      // Allora BarsCount è uguale al numero di barre
      BarsCount = Bars(Symbol(),PERIOD_CURRENT);
      // Ritorni True
      return true;
     }
// Altrimenti ritorni falso
   else
      return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// Funzione che calcola il valore di un pip e lo ritorna in una variabile
double CInfo::Pips()
  {
// Se le digits sono maggiori o uguali a 3 vuol dire che è Forex
   if(Digits() >= 3)
      return pips = Point()*10;
   else
      return pips = Point();

  }
// Ritorna true se ci sono posizioni aperte dal nostro EA
bool CInfo::CiSonoPosizioni(int magic, string symbol, ENUM_POSITION_TYPE tipoposizione)
  {

   long position_magic =0.0;
   string position_symbol="";
   long tipo=0.0;

   for(int i = 0 ; i < PositionsTotal() ; i++)
     {

      ulong ticket = PositionGetTicket(i);

      //In delle variabili printiamo i valori della posizione selezionata che ci servono
      position_magic = PositionGetInteger(POSITION_MAGIC);
      position_symbol = PositionGetString(POSITION_SYMBOL);
      tipo = PositionGetInteger(POSITION_TYPE);

      // Se la posizione ha il simbolo e il magic uguali a quelli immessi come input ritorna true
      if(symbol == position_symbol && position_magic ==magic && tipoposizione == tipo)

         // Ci sono posizione attualmente aperte nel simbolo scelto e del magic scelto
         return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//Ritorna true se ci sono i nostri ordini
bool CInfo::CiSonoOrdini(int magico,string simbolo, ENUM_ORDER_TYPE tipoordine)
  {

//Inizializzazione variabili
   ulong    ticket;
   double   open_price;
   double   initial_volume;
   datetime time_setup;
   string   order_symbol;
   long     order_type;
   long     order_magic;
   long     positionID;

//OrdersTotal() ci ritorna i Pendenti aperti attualmente
   uint     total=OrdersTotal();

//Cicliamo questi pendenti
   for(uint i=0; i<total; i++)
     {
      //Con OrderGetTicket selezioniamo e immagazziniamo il ticket (2 azioni in una)
      if((ticket=OrderGetTicket(i))>0)
        {

         //Assegnamo alle variabili i valori dell'ordine selezionato
         open_price    =OrderGetDouble(ORDER_PRICE_OPEN);
         time_setup    =(datetime)OrderGetInteger(ORDER_TIME_SETUP);
         order_symbol  =OrderGetString(ORDER_SYMBOL);
         order_magic   =OrderGetInteger(ORDER_MAGIC);
         positionID    =OrderGetInteger(ORDER_POSITION_ID);
         initial_volume=OrderGetDouble(ORDER_VOLUME_INITIAL);
         order_type    =OrderGetInteger(ORDER_TYPE);

         //Se l'ordine è sul nostro simbolo ed ha il nostro magic number ritorna true
         if(order_magic==magico && order_symbol == simbolo && order_type == tipoordine)
           {
            return true;
           }
        }
     }
//Se il ciclo non entra ritorna false
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
DealInfo CInfo::InfoUltimoDeal(string Mercato, int Magico)
  {
// Inizializza la struttura con valori predefiniti
   DealInfo ultimoDeal = {0, "", DEAL_ENTRY_IN, DEAL_TYPE_BUY, 0, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0};

// Richiedi la History completa di ordini e deals
   HistorySelect(0, TimeCurrent());

// A total impostiamo la quantità di deals della history
   uint total = HistoryDealsTotal();

// Uno ad uno cicliamo questi deal per coglierne le proprietà
   for(uint i = 0; i < total; i++)
     {
      // Impostiamo alla variabile ticket il ticket del deal preso dalla history
      ulong ticket = HistoryDealGetTicket(i);

      // Se è maggiore di zero assegnamo alle variabili le proprietà del deal selezionato
      if(ticket > 0)
        {
         // Prendiamo le proprietà del deal selezionato
         datetime time = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
         string symbol = HistoryDealGetString(ticket, DEAL_SYMBOL);
         long magic = HistoryDealGetInteger(ticket, DEAL_MAGIC);
         double volume = HistoryDealGetDouble(ticket, DEAL_VOLUME);
         double price = HistoryDealGetDouble(ticket, DEAL_PRICE);
         double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
         double fee = HistoryDealGetDouble(ticket, DEAL_FEE);
         double commission = HistoryDealGetDouble(ticket, DEAL_COMMISSION);
         double swap = HistoryDealGetDouble(ticket, DEAL_SWAP);
         double take = HistoryDealGetDouble(ticket, DEAL_TP);
         double stop = HistoryDealGetDouble(ticket, DEAL_SL);
         ENUM_DEAL_ENTRY tipo_entrata = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket, DEAL_ENTRY);
         ENUM_DEAL_TYPE tipo_deal = (ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket, DEAL_TYPE);

         if(symbol == Mercato && magic == Magico)
           {
            // Se il time del deal è maggiore al time del deal selezionato allora vuol dire che c'è un nuovo DEAL
            if(ultimoDeal.time < time)
              {
               // Immagazziniamo le informazioni del deal così possiamo ritornarle alla fine
               ultimoDeal.ticket = ticket;
               ultimoDeal.symbol = symbol;
               ultimoDeal.tipo_entrata = tipo_entrata;
               ultimoDeal.tipo_deal = tipo_deal;
               ultimoDeal.time = time;
               ultimoDeal.magic = magic;
               ultimoDeal.volume = volume;
               ultimoDeal.price = price;
               ultimoDeal.profit = profit;
               ultimoDeal.fee = fee;
               ultimoDeal.commission = commission;
               ultimoDeal.swap = swap;
               ultimoDeal.take = take;
               ultimoDeal.stop = stop;
              }
           }
        }
     }
// Ci ritorna la struttura contenente le informazioni dell'ultimo DEAL
   return ultimoDeal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
PositionInfo CInfo::InfoUltimaPosizione(string Mercato, int Magico)
  {
// Inizializza la struttura con valori predefiniti
   PositionInfo ultimaPosizione = {0, "", 0, POSITION_TYPE_BUY, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0};

// Con un ciclo for analiziamo ogni POSIZIONE aperta grazie a PositionsTotal
   for(int i = 0; i < PositionsTotal(); i++)
     {
      // Selezioniamo il ticket della posizione
      ulong ticket = PositionGetTicket(i);

      // Se il ticket è stato selezionato prendiamo tutti i valori della posizione che ci servono
      if(ticket > 0)
        {
         long magic = PositionGetInteger(POSITION_MAGIC);
         string symbol = PositionGetString(POSITION_SYMBOL);
         datetime time = (datetime)PositionGetInteger(POSITION_TIME);
         ENUM_POSITION_TYPE tipo = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         double volume = PositionGetDouble(POSITION_VOLUME);
         double price_open = PositionGetDouble(POSITION_PRICE_OPEN);
         double stop = PositionGetDouble(POSITION_SL);
         double take = PositionGetDouble(POSITION_TP);
         double swap = PositionGetDouble(POSITION_SWAP);
         double profit = PositionGetDouble(POSITION_PROFIT);

         // Se la posizione ha il nostro simbolo e il nostro magic
         if(Mercato == symbol && magic == Magico)
           {
            // Se il time della posizione è maggiore al tempo della nuova posizione
            if(ultimaPosizione.time < time)
              {
               // Immagazziniamo le informazioni della posizione così possiamo ritornarle alla fine
               ultimaPosizione.ticket = ticket;
               ultimaPosizione.symbol = symbol;
               ultimaPosizione.time = time;
               ultimaPosizione.tipo = tipo;
               ultimaPosizione.magic = magic;
               ultimaPosizione.volume = volume;
               ultimaPosizione.price_open = price_open;
               ultimaPosizione.stop = stop;
               ultimaPosizione.take = take;
               ultimaPosizione.swap = swap;
               ultimaPosizione.profit = profit;
              }
           }
        }
     }
// Ci ritorna la struttura contenente le informazioni dell'ultima posizione
   return ultimaPosizione;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
OrderInfo CInfo::InfoUltimoOrdine(string Mercato, int Magico)
  {
// Inizializza la struttura con valori predefiniti
   OrderInfo ultimoOrdine = {0, "", 0, 0, ORDER_TYPE_BUY, 0, 0.0, 0.0, 0.0};

// OrdersTotal() ci ritorna i Pendenti aperti attualmente
   uint total = OrdersTotal();

// Cicliamo questi pendenti
   for(uint i = 0; i < total; i++)
     {
      // Con OrderGetTicket selezioniamo e immagazziniamo il ticket (2 azioni in una)
      ulong ticket = OrderGetTicket(i);

      // Se il ticket è stato selezionato, prendiamo tutti i valori dell'ordine che ci servono
      if(ticket > 0)
        {
         double stop = OrderGetDouble(ORDER_SL);
         double take = OrderGetDouble(ORDER_TP);
         datetime time_inserimento = (datetime)OrderGetInteger(ORDER_TIME_SETUP);
         datetime time_cancellazione = (datetime)OrderGetInteger(ORDER_TIME_EXPIRATION);
         string symbol = OrderGetString(ORDER_SYMBOL);
         long magic = OrderGetInteger(ORDER_MAGIC);
         double volume = OrderGetDouble(ORDER_VOLUME_INITIAL);
         ENUM_ORDER_TYPE tipo = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);

         // Se l'ordine è sul nostro simbolo ed ha il nostro magic number
         if(magic == Magico && symbol == Mercato)
           {
            // Se il time dell'ordine è maggiore al tempo del nuovo ordine
            if(ultimoOrdine.time_inserimento < time_inserimento)
              {
               // Immagazziniamo le informazioni dell'ordine così possiamo ritornarle alla fine
               ultimoOrdine.ticket = ticket;
               ultimoOrdine.symbol = symbol;
               ultimoOrdine.time_inserimento = time_inserimento;
               ultimoOrdine.time_cancellazione = time_cancellazione;
               ultimoOrdine.tipo = tipo;
               ultimoOrdine.magic = magic;
               ultimoOrdine.volume = volume;
               ultimoOrdine.stop = stop;
               ultimoOrdine.take = take;
              }
           }
        }
     }
// Ci ritorna la struttura contenente le informazioni dell'ultimo ordine
   return ultimoOrdine;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime CInfo::StartOfToday()
  {
   datetime todayTime = TimeCurrent() - (TimeCurrent() % 86400);
   return todayTime;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime CInfo::EndOfToday()
  {
   return StartOfToday() + 86400;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CInfo::RisultatoDealsGiornalieri(int magic, string simbolo)
  {
   double risultato = 0.0;

   HistorySelect(StartOfToday(), EndOfToday());

   for(int i = 0; i < HistoryDealsTotal(); i++)
     {
      ulong ticket = HistoryDealGetTicket(i);
      string deal_symbol = HistoryDealGetString(ticket, DEAL_SYMBOL);
      long deal_entry = HistoryDealGetInteger(ticket, DEAL_ENTRY);
      long deal_magic = HistoryDealGetInteger(ticket, DEAL_MAGIC);
      double deal_profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
      double deal_commision = HistoryDealGetDouble(ticket, DEAL_COMMISSION);
      double deal_swap = HistoryDealGetDouble(ticket, DEAL_SWAP);
      long deal_close_time = HistoryDealGetInteger(ticket, DEAL_TIME);

      if(deal_symbol == simbolo && deal_magic == magic && deal_entry == DEAL_ENTRY_OUT && deal_close_time >= StartOfToday())
        {
         double risultatoDeal = deal_profit + deal_commision + deal_swap;
         risultato += risultatoDeal;
        }
     }
   return risultato;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CInfo::RisultatoPosizioniAperte(int magic, string simbolo)
  {
   double risultatoPosizioni = 0.0;

   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);
      long position_magic = PositionGetInteger(POSITION_MAGIC);
      string position_symbol = PositionGetString(POSITION_SYMBOL);
      double position_profit = PositionGetDouble(POSITION_PROFIT);
      double position_swap = PositionGetDouble(POSITION_SWAP);

      if(simbolo == position_symbol && magic == position_magic)
        {
         risultatoPosizioni = position_profit + position_swap;
        }
     }
   return risultatoPosizioni;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CInfo::RisultatoGiornaliero(int magic, string simbolo)
  {
   double profittoPerditaTotali = RisultatoDealsGiornalieri(magic, simbolo) + RisultatoPosizioniAperte(magic,simbolo);
   return profittoPerditaTotali;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CInfo::PassateBarreDaPerdita(int magic, string simbolo, ENUM_TIMEFRAMES periodo, int candele)
  {
// Ottieni le informazioni dell'ultimo deal di chiusura
   DealInfo ultimoDeal = InfoUltimoDeal(simbolo, magic);

// Verifica se l'ultimo deal è stato chiuso in perdita
   if(ultimoDeal.profit < 0 && ultimoDeal.tipo_entrata == DEAL_ENTRY_OUT)
     {
      // Ottieni l'orario dell'ultimo deal di chiusura
      datetime time = ultimoDeal.time;

      // Verifica se sono passate il numero di candele specificate
      if(iTime(simbolo, periodo, candele) >= time)
        {
         return true;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CInfo::PassateTotCandele(int candele,string simbolo, ENUM_TIMEFRAMES periodo, datetime orario)
  {
// Sono passate tot candele da orario
   if(iTime(simbolo,periodo,candele) >= orario)
     {
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CInfo::Massimo(int candele_totali,int candela_inizio)
  {
   int indiceMassimo=iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,candele_totali,candela_inizio);
   double Massimo=NormalizeDouble(iHigh(Symbol(),PERIOD_CURRENT,indiceMassimo),Digits());

   return Massimo;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CInfo::Minimo(int candele_totali,int candela_inizio)
  {
   int indiceMinimo=iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,candele_totali,candela_inizio);
   double Minimo=NormalizeDouble(iLow(Symbol(),PERIOD_CURRENT,indiceMinimo),Digits());

   return Minimo;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CInfo::Bid()
  {
   double bid = SymbolInfoDouble(Symbol(),SYMBOL_BID);

   return NormalizeDouble(bid,Digits());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CInfo::Ask()
  {
   double ask = SymbolInfoDouble(Symbol(),SYMBOL_ASK);

   return NormalizeDouble(ask,Digits());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MqlDateTime CInfo::Tempo()
  {
// Ottieni il tempo corrente
   datetime currentTime = TimeCurrent();

// Inizializza la struttura MqlDateTime
   MqlDateTime dateTimeStruct;

// Converte il tempo corrente nella struttura MqlDateTime
   TimeToStruct(currentTime, dateTimeStruct);

// Ritorna la struttura popolata
   return dateTimeStruct;
  }
//+------------------------------------------------------------------+
bool CInfo::IsInTimeRange(datetime datainiziale,datetime datafinale)
  {
   datetime date = TimeCurrent();
   return (date >= datainiziale && date <= datafinale);
  }
//+------------------------------------------------------------------+
