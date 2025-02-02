//+------------------------------------------------------------------+
//|                                                         Main.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

// Librerie FQInclude collegate a repository su GitHub
// Test 1 Cambiato master a main branch
// Ho cambiato il nome della repo da FQ-Include a FQInclude

//+------------------------------------------------------------------+
//| File che serve per includere tutte le mie librerie               |
//+------------------------------------------------------------------+

#include <FQInclude\Info\Rischio\Rischio.mqh>                       // Libreria per gestire il lottaggio
#include <FQInclude\Info\Gestione\Trailing\Trailing.mqh>            // Libreria per gestire i trailing stop
#include <FQInclude\Info\Database\Notizie\Notizie.mqh>              // Libreria per gestire le notizie nel database 
#include <FQInclude\Info\Database\Andamento\Andamento.mqh>          // Libreria per gestire il database dell'andamento 
#include <FQInclude\Segnali\Tipo\NotizieLive.mqh>                   // Libreria per gestire le notizie live
#include <FQInclude\Segnali\Tipo\PatternDiPrezzo.mqh>               // Libreria per gestire i segnali sui pattern di prezzo 
#include <FQInclude\Segnali\Tipo\DeviazioneStandard.mqh>            // Libreria per gestire i segnali sulla deviazione standard       
#include <FQInclude\Segnali\Tipo\BandeDiBollinger.mqh>              // Libreria per gestire i segnali sulle bande di bollinger
#include <FQInclude\Segnali\Tipo\Tendenza.mqh>                      // Libreria per gestire i segnali sulla tendenza del prezzo
//+------------------------------------------------------------------+