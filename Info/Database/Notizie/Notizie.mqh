//+------------------------------------------------------------------+
//|                                                      Notizie.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include <FQInclude\Info\Database\Database.mqh>

enum ENUM_VALUTA
  {
   AUD, //Dollaro autraliano
   BRL, //Real brasiliano
   CAD, //Dollaro canadese
   CHF, //Franco svizzero
   CNT, //Yuan cinese
   EUR, //Euro
   GBP, //Sterlina
   HKD, //Dollaro di Hong Kong
   INR, //Rupia indiana
   JPY, //Yen giapponese
   KRW, //Won sudcoreano
   MXN, //Peso messicano
   NOK, //Corona norvegese
   NZD, //Dollaro neozelandese
   SEK, //Corona svedese
   SGD, //Dollaro di Singapore
   USD, //Dollari americani
   ZAR  //Rand sudafricano
  };

struct InfoNotizia
  {
   datetime          data;
   string            nome;
   double            attuale;
   double            previsto;
   double            precedente;
   string            attuale_previsto;
   string            attuale_precedente;
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CNotizie : public CDatabase
  {

private:
   int               pos_GDP(string nome_evento);
   int               pos_INT(string nome_evento);
   int               pos_NFP(string nome_evento);
   int               pos_CPI(string nome_evento);
   string            QueryNotizie(string table_name,datetime data_evento, string nome_evento, double Attuale, double Previsto, double Precedente);
   string            QueryNome(string time_current,string table_name);
   string            QueryAttualePrevisto(string time_current,string table_name);
   string            QueryAttualePrecedente(string time_current,string table_name);
   string            QueryAttuale(string time_current,string table_name);
   string            QueryData(string time_current,string table_name);
   string            QueryPrecedente(string time_current,string table_name);
   string            QueryPrevisto(string time_current,string table_name);

public:

                     CNotizie() {};
                    ~CNotizie() {};

   void              InitDatabase(string valuta);
   void              UpdateDatabase(string valuta,datetime from);
   InfoNotizia       UltimaNotizia(int database_handle,string table_name);
   string            Variazione(string valuta, string tabella, int minuti, string colonna, int valoreBUY, int valoreSELL);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CNotizie::pos_GDP(string nome_evento)
  {
   int ritorno_posizione = -1;

   ritorno_posizione = (ritorno_posizione == -1) ? StringFind(nome_evento, "PIL") : ritorno_posizione;

   return ritorno_posizione;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CNotizie::pos_INT(string nome_evento)
  {
   int ritorno_posizione = -1;

   ritorno_posizione = (ritorno_posizione == -1) ? StringFind(nome_evento, "Interesse") : ritorno_posizione;
   ritorno_posizione = (ritorno_posizione == -1) ? StringFind(nome_evento, "interesse") : ritorno_posizione;

   return ritorno_posizione;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CNotizie::pos_NFP(string nome_evento)
  {
   int ritorno_posizione = -1;

   ritorno_posizione = (ritorno_posizione == -1) ? StringFind(nome_evento, "Agricoli") : ritorno_posizione;

   return ritorno_posizione;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CNotizie::pos_CPI(string nome_evento)
  {
   int ritorno_posizione = -1;

   ritorno_posizione = (ritorno_posizione == -1) ? StringFind(nome_evento, "IPC") : ritorno_posizione;

   return ritorno_posizione;
  }
//+------------------------------------------------------------------+
string CNotizie::QueryNotizie(string table_name, datetime time, string event_name, double attuale, double previsto, double precedente)
  {
   string giorno = TimeToString(time, TIME_DATE | TIME_MINUTES);
   double Attuale_Previsto_percent = (previsto != 0) ? NormalizeDouble(((attuale - previsto) / previsto) * 100, 2) : 0;
   double Attuale_Precedente_percent = (precedente != 0) ? NormalizeDouble(((attuale - precedente) / precedente) * 100, 2) : 0;
   string Attuale_Previsto = StringFormat("%.2f%%", Attuale_Previsto_percent);
   string Attuale_Precedente = StringFormat("%.2f%%", Attuale_Precedente_percent);

   return StringFormat("INSERT OR REPLACE INTO %s (Data,Nome,Attuale,Previsto,Precedente,Attuale_Previsto,Attuale_Precedente) VALUES ('%s','%s',%f,%f,%f,'%s','%s');",
                       table_name,
                       giorno,
                       event_name,
                       attuale,
                       previsto,
                       precedente,
                       Attuale_Previsto,
                       Attuale_Precedente
                      );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CNotizie::InitDatabase(string valuta)
  {
   string QUERY[];
   string TableName[] = {"CPI", "Interest", "NFP", "GDP"};
   const int tableCount = ArraySize(TableName);

// Inizializzare l'array QUERY con la stessa dimensione di TableName
   ArrayResize(QUERY, tableCount);

   int handle_database = ApriDatabase("Notizie_"+valuta);

// Costruire le query per la creazione delle tabelle
   for(int i = 0; i < tableCount; i++)
     {
      QUERY[i] = "CREATE TABLE " + TableName[i] + " ("
                 "Data TEXT,"
                 "Nome TEXT,"
                 "Attuale REAL,"
                 "Previsto REAL,"
                 "Precedente REAL,"
                 "Attuale_Previsto REAL,"
                 "Attuale_Precedente REAL);";
     }

// Creare le tabelle nel database
   for(int i = 0; i < tableCount; i++)
     {
      CancellaTabella(handle_database, TableName[i]);
      CreaTabella(handle_database, TableName[i], QUERY[i]);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CNotizie::UpdateDatabase(string valuta, datetime from)
  {
   int handle = ApriDatabase("Notizie_" + valuta);
   MqlCalendarValue out_values[];

   int valuesTotal = CalendarValueHistory(out_values, from, TimeTradeServer());

   for(int i = 0; i < valuesTotal; i++)
     {
      MqlCalendarEvent event;
      CalendarEventById(out_values[i].event_id, event);

      MqlCalendarCountry country;
      CalendarCountryById(event.country_id, country);

      if(country.currency == valuta)
        {
         double attuale = (out_values[i].actual_value == -9223372036854775808) ? 0 : NormalizeDouble(out_values[i].actual_value, 2);
         double precedente = (out_values[i].prev_value == -9223372036854775808) ? 0 : NormalizeDouble(out_values[i].prev_value, 2);
         double previsto = (out_values[i].forecast_value == -9223372036854775808) ? 0 : NormalizeDouble(out_values[i].forecast_value, 2);

         if(pos_CPI(event.name) >= 0)
            InserisciQuery(handle, QueryNotizie("CPI", out_values[i].time, event.name, attuale, previsto, precedente));
         if(pos_INT(event.name) >= 0)
            InserisciQuery(handle, QueryNotizie("Interest", out_values[i].time, event.name, attuale, previsto, precedente));
         if(pos_NFP(event.name) >= 0)
            InserisciQuery(handle, QueryNotizie("NFP", out_values[i].time, event.name, attuale, previsto, precedente));
         if(pos_GDP(event.name) >= 0)
            InserisciQuery(handle, QueryNotizie("GDP", out_values[i].time, event.name, attuale, previsto, precedente));
        }
     }

   ChiudiDatabase(handle);
  }
//+------------------------------------------------------------------+
InfoNotizia CNotizie::UltimaNotizia(int database_handle, string table_name)
  {
// Convertiamo `timecurrent` in una stringa adatta per la query SQL
   string time_current = TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES);
   InfoNotizia struttura;

   string query[]=
     {
      QueryData(time_current,table_name),
      QueryAttuale(time_current,table_name),
      QueryPrecedente(time_current,table_name),
      QueryPrevisto(time_current,table_name),
      QueryNome(time_current,table_name),
      QueryAttualePrevisto(time_current,table_name),
      QueryAttualePrecedente(time_current,table_name)
     };

   struttura.data=(datetime)RitornaStringa(database_handle,query[0]);
   struttura.attuale = RitornaInteger(database_handle,query[1]);
   struttura.precedente = RitornaInteger(database_handle,query[2]);
   struttura.previsto = RitornaInteger(database_handle,query[3]);
   struttura.nome = RitornaStringa(database_handle,query[4]);
   struttura.attuale_previsto = RitornaStringa(database_handle,query[5]);
   struttura.attuale_precedente = RitornaStringa(database_handle,query[6]);

   return struttura;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CNotizie::QueryNome(string time_current,string table_name)
  {
   string sql = "SELECT Nome FROM " + table_name +
                " WHERE Data <= '" + time_current +
                "' ORDER BY Data DESC LIMIT 1";

   return sql;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CNotizie::QueryAttualePrevisto(string time_current,string table_name)
  {
   string sql = "SELECT Attuale_Previsto FROM " + table_name +
                " WHERE Data <= '" + time_current +
                "' ORDER BY Data DESC LIMIT 1";

   return sql;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CNotizie::QueryAttualePrecedente(string time_current,string table_name)
  {
   string sql = "SELECT Attuale_Precedente FROM " + table_name +
                " WHERE Data <= '" + time_current +
                "' ORDER BY Data DESC LIMIT 1";

   return sql;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CNotizie::QueryAttuale(string time_current,string table_name)
  {
   string sql = "SELECT Attuale FROM " + table_name +
                " WHERE Data <= '" + time_current +
                "' ORDER BY Data DESC LIMIT 1";

   return sql;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CNotizie::QueryData(string time_current,string table_name)
  {
   string sql = "SELECT Data FROM " + table_name +
                " WHERE Data <= '" + time_current +
                "' ORDER BY Data DESC LIMIT 1";

   return sql;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CNotizie::QueryPrecedente(string time_current,string table_name)
  {
   string sql = "SELECT Precedente FROM " + table_name +
                " WHERE Data <= '" + time_current +
                "' ORDER BY Data DESC LIMIT 1";

   return sql;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CNotizie::QueryPrevisto(string time_current,string table_name)
  {
   string sql = "SELECT Previsto FROM " + table_name +
                " WHERE Data <= '" + time_current +
                "' ORDER BY Data DESC LIMIT 1";

   return sql;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CNotizie::Variazione(string valuta, string tabella, int ore, string colonna, int valoreBUY, int valoreSELL)
  {
   string entrata = "";
   double attuale_previsto, attuale_precedente;
   string nomedatabase = "Notizie_" + valuta + ".sqlite";
   int handle = ApriDatabase(nomedatabase);
   InfoNotizia News = UltimaNotizia(handle, tabella);

   datetime finedata = News.data + (3600 * ore);

   if(IsInTimeRange(News.data, finedata))
     {

      Print((string)News.data
            + " " + News.nome
            + " Attuale:" + DoubleToString(News.attuale)
            + " Previsto:" + DoubleToString(News.previsto)
            + " Precedente:" + DoubleToString(News.precedente)
            + " Attuale_Previsto:" + News.attuale_previsto
            + " Attuale_Prevedente:" + News.attuale_precedente);


      if(colonna == "previsto")
        {
         attuale_previsto = NormalizeDouble(((News.attuale - News.previsto) / News.previsto) * 100, 2);
         if(attuale_previsto > valoreBUY)
            entrata = "positivo";
         else
            if(attuale_previsto < -valoreSELL)
               entrata = "negativo";
            else
               if(attuale_previsto == -valoreSELL || attuale_previsto == valoreBUY)
                  entrata = "uguale";
        }
      else
         if(colonna == "precedente")
           {
            attuale_precedente = NormalizeDouble(((News.attuale - News.precedente) / News.precedente) * 100, 2);
            if(attuale_precedente > valoreBUY)
               entrata = "positivo";
            else
               if(attuale_precedente < -valoreSELL)
                  entrata = "negativo";
               else
                  if(attuale_precedente == -valoreSELL || attuale_precedente == valoreBUY)
                     entrata = "uguale";
           }
     }

   ChiudiDatabase(handle);
   return entrata;
  }
//+------------------------------------------------------------------+
