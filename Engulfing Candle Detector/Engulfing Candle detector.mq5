#property copyright                             "Copyright 2023, Shin Eun Gu"
#property link                                  "https://www.buymeacoffee.com/ss2299"
#property version                               "2.3"
#property indicator_chart_window                "Engulfing Candle detector"
#property description                           "Click the link to buy some coffee for us"
#property description                           "Your help would be making this indicator better"
#property description                           "https://www.buymeacoffee.com/ss2299"
#property indicator_chart_window
#property indicator_buffers                     1
#property indicator_plots                       1
//#property strict

enum ENUM_ENGULFING {
   None=0,                 // Disable
   ENGULFING_BODY=1,       // Engulfing with Body
   ENGULFING_SHADOW=2,     // Engulfing with Shadow (Highest-Lowest)
};


//--- input parameters
input    string             inGroupName1      = "-- Double canedles --";                // Detect Patterns
input    ENUM_ENGULFING     inEnalbeEngulfing = ENGULFING_BODY;                         // Enable Engulfing
input    string             inBlank1          = "";                                     // .

input    string             inGroupName2      = "-- Single candle --";                  // Filtering Condition
input    bool               inEnableMarubozu  = false;                                  // Enable Marubozu
input    int                inMarubozuPercent = 70;                                     // Marubozu Body % (0 ... 100)
input    string             inBlank2          = "";                                     // .

input    string             inGroupName3      = "-- Common --";                         // Visualization
input    int                inLookback        = 150;                                    // Lookback
input    color              inBullishColour   = clrLime;                                // Bullish colour
input    color              inBearishColour   = clrRed;                                 // Bearish colour
input    string             inBlank3          = "";                                     // .

input    string             inGroupName4      = "-- Highlight Candle --";               // Visualization
input    bool               inEnableHighlight = false;                                  // Enable highlight engulfing candle
input    string             inBlank4          = "";                                     // .

input    string             inGroupName5      = "-- Guide Price Line --";               // Visualization
input    bool               inEnableHLine     = false;                                  // Enable Hline drawing (50% of engulfing candle)
input    int                inLineWidth       = 1;                                      // Line width
input    string             inBlank5          = "";                                     // .

input    string             inGroupName6      = "-- Guide Price Box --";                // Visualization
input    bool               inEnableGuideBox  = true;                                   // Enable rectangle to guide price 1 and price 2
input    bool               inEnableBox161    = false;                                  // Enable rectangle with region of price 161.8
input    bool               InpFill           = true;                                   // Filling the rectangle with color 
input    ENUM_LINE_STYLE    inBox161LineStyle = STYLE_DOT;                              // Line Style of Box 161
input    int                inGuideBoxPeriod  = 30;                                     // Period of the guide box
input    double             inGuideBoxPrice1  = 0.50;                                   // Guide price 1 from the engulfing candle
input    double             inGuideBoxPrice2  = 0.618;                                  // Guide price 2 from the engulfing candle

// Prefix for drawing objects
#define  PrefixBox          "EngulfingBox_"
#define  PrefixHighlight    "EngulfingHighlight_"
#define  PrefixBoxShadow    "EngulfingBoxShadow_"
#define  PrefixBox161       "EngulfingBox161_"
#define  PrefixHLine        "EngulfingHLine_"

// Last candle candle time
datetime LastActionTime = 0;

int OnInit()  {

   EventSetTimer(1);
   
   return(INIT_SUCCEEDED); 
}

void OnDeinit(const int reason){

   clearScreen();
   EventKillTimer();
}



int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])  {
                
   return(rates_total);
}


void OnTimer()  {

   if (GetLastError() == 0) {      
      if (LastActionTime != iTime(NULL, 0, 1))  {
         displayEngulfing();
         LastActionTime = iTime(NULL, 0, 1);
      }
   }  
}


void displayEngulfing()  {

   string str;
   double price1, price2;
   
   int resEngulfing;
   int resEngulfingShadow;
   int resMarobozu;

   clearScreen();

   for (int i=0; i<inLookback; i++)  {
      
      resEngulfing = isEngulfing(i);
      resEngulfingShadow = isEngulfingShadow(i);
      resMarobozu = isMarubozu(i);
      
      // Engulfing with Body
      if (inEnalbeEngulfing == 1 && !inEnableMarubozu)  {
         if (resEngulfing > 0) {
            if (inEnableGuideBox) {
               StringConcatenate(str, PrefixBox, i);
               price1 = calcGuideprice(iOpen(_Symbol,PERIOD_CURRENT,i), iClose(_Symbol,PERIOD_CURRENT,i), inGuideBoxPrice1);
               price2 = calcGuideprice(iOpen(_Symbol,PERIOD_CURRENT,i), iClose(_Symbol,PERIOD_CURRENT,i), inGuideBoxPrice2);
               createBox(str, resEngulfing, i, price1, price2);
            }
            
            // Highlight Box
            if (inEnableHighlight)  {
               StringConcatenate(str, PrefixHighlight, i);
               createHighlight(str, resEngulfing, i, iOpen(_Symbol,PERIOD_CURRENT,i), iClose(_Symbol,PERIOD_CURRENT,i));
            }

            // HLine
            if (inEnableHLine)  {
               StringConcatenate(str, PrefixHLine, i);
               price1 = calcGuideprice(iOpen(_Symbol,PERIOD_CURRENT,i), iClose(_Symbol,PERIOD_CURRENT,i), 0.5);
               createHLine(str, resEngulfing, i, price1);
            }

            // Box161
            if (inEnableBox161)  {
               StringConcatenate(str, PrefixBox161, i);
               price1 = calcGuideprice(iOpen(_Symbol,PERIOD_CURRENT,i), iClose(_Symbol,PERIOD_CURRENT,i), 0);
               price2 = calcGuideprice(iOpen(_Symbol,PERIOD_CURRENT,i), iClose(_Symbol,PERIOD_CURRENT,i), 1.618);
               createBox161(str, resEngulfing, i, price1, price2);
            }
         }
      }
      else if (inEnalbeEngulfing == 1 && inEnableMarubozu)  {
         if (resEngulfing > 0 && resMarobozu > 0) {
            if (inEnableGuideBox) {
               StringConcatenate(str, PrefixBox, i);
               price1 = calcGuideprice(iOpen(_Symbol,PERIOD_CURRENT,i), iClose(_Symbol,PERIOD_CURRENT,i), inGuideBoxPrice1);
               price2 = calcGuideprice(iOpen(_Symbol,PERIOD_CURRENT,i), iClose(_Symbol,PERIOD_CURRENT,i), inGuideBoxPrice2);
               createBox(str, resEngulfing, i, price1, price2);
            }
            
            // Highlight Box
            if (inEnableHighlight)  {
               StringConcatenate(str, PrefixHighlight, i);
               createHighlight(str, resEngulfing, i, iOpen(_Symbol,PERIOD_CURRENT,i), iClose(_Symbol,PERIOD_CURRENT,i));
            }

            // HLine
            if (inEnableHLine)  {
               StringConcatenate(str, PrefixHLine, i);
               price1 = calcGuideprice(iOpen(_Symbol,PERIOD_CURRENT,i), iClose(_Symbol,PERIOD_CURRENT,i), 0.5);
               createHLine(str, resEngulfing, i, price1);
            }

            // Box161
            if (inEnableBox161)  {
               StringConcatenate(str, PrefixBox161, i);
               price1 = calcGuideprice(iOpen(_Symbol,PERIOD_CURRENT,i), iClose(_Symbol,PERIOD_CURRENT,i), 0);
               price2 = calcGuideprice(iOpen(_Symbol,PERIOD_CURRENT,i), iClose(_Symbol,PERIOD_CURRENT,i), 1.618);
               createBox161(str, resEngulfing, i, price1, price2);
            }
         }
      }

      // Engulfing with Shadow
      if (inEnalbeEngulfing == 2 && !inEnableMarubozu)  {
         if (resEngulfingShadow > 0)  {
            if (inEnableGuideBox) {
               StringConcatenate(str, PrefixBox, i);
               ObjectDelete(0, str);
   
               StringConcatenate(str, PrefixBoxShadow, i);
               price1 = calcGuideprice(iHigh(_Symbol,PERIOD_CURRENT,i), iLow(_Symbol,PERIOD_CURRENT,i), inGuideBoxPrice1);
               price2 = calcGuideprice(iHigh(_Symbol,PERIOD_CURRENT,i), iLow(_Symbol,PERIOD_CURRENT,i), inGuideBoxPrice2);
               createBox(str, resEngulfingShadow, i, price1, price2);
            }
            

            // Highlight Box
            if (inEnableHighlight)  {
               StringConcatenate(str, PrefixHighlight, i);
               ObjectDelete(0, str);   // Remove objects from detected by body

               StringConcatenate(str, PrefixHighlight, i);
               createHighlight(str, resEngulfingShadow, i, iHigh(_Symbol,PERIOD_CURRENT,i), iLow(_Symbol,PERIOD_CURRENT,i));
            }

            // HLine
            if (inEnableHLine)  {
               StringConcatenate(str, PrefixHLine, i);
               ObjectDelete(0, str);   // Remove objects from detected by body

               price1 = calcGuideprice(iHigh(_Symbol,PERIOD_CURRENT,i), iLow(_Symbol,PERIOD_CURRENT,i), 0.5);
               createHLine(str, resEngulfingShadow, i, price1);
            }

            // Box161
            if (inEnableBox161)  {
               StringConcatenate(str, PrefixBox161, i);
               ObjectDelete(0, str);   // Remove objects from detected by body

               price1 = calcGuideprice(iHigh(_Symbol,PERIOD_CURRENT,i), iLow(_Symbol,PERIOD_CURRENT,i), 0);
               price2 = calcGuideprice(iHigh(_Symbol,PERIOD_CURRENT,i), iLow(_Symbol,PERIOD_CURRENT,i), 1.618);
               createBox161(str, resEngulfingShadow, i, price1, price2);
            }
         }
      }
      else if (inEnalbeEngulfing == 2 && inEnableMarubozu)  {
         if (resEngulfingShadow > 0 && resMarobozu > 0)  {
            if (inEnableGuideBox) {
               StringConcatenate(str, PrefixBox, i);
               ObjectDelete(0, str);
   
               StringConcatenate(str, PrefixBoxShadow, i);
               price1 = calcGuideprice(iHigh(_Symbol,PERIOD_CURRENT,i), iLow(_Symbol,PERIOD_CURRENT,i), inGuideBoxPrice1);
               price2 = calcGuideprice(iHigh(_Symbol,PERIOD_CURRENT,i), iLow(_Symbol,PERIOD_CURRENT,i), inGuideBoxPrice2);
               createBox(str, resEngulfingShadow, i, price1, price2);
            }
            

            // Highlight Box
            if (inEnableHighlight)  {
               StringConcatenate(str, PrefixHighlight, i);
               ObjectDelete(0, str);   // Remove objects from detected by body

               StringConcatenate(str, PrefixHighlight, i);
               createHighlight(str, resEngulfingShadow, i, iHigh(_Symbol,PERIOD_CURRENT,i), iLow(_Symbol,PERIOD_CURRENT,i));
            }

            // HLine
            if (inEnableHLine)  {
               StringConcatenate(str, PrefixHLine, i);
               ObjectDelete(0, str);   // Remove objects from detected by body

               price1 = calcGuideprice(iHigh(_Symbol,PERIOD_CURRENT,i), iLow(_Symbol,PERIOD_CURRENT,i), 0.5);
               createHLine(str, resEngulfingShadow, i, price1);
            }

            // Box161
            if (inEnableBox161)  {
               StringConcatenate(str, PrefixBox161, i);
               ObjectDelete(0, str);   // Remove objects from detected by body

               price1 = calcGuideprice(iHigh(_Symbol,PERIOD_CURRENT,i), iLow(_Symbol,PERIOD_CURRENT,i), 0);
               price2 = calcGuideprice(iHigh(_Symbol,PERIOD_CURRENT,i), iLow(_Symbol,PERIOD_CURRENT,i), 1.618);
               createBox161(str, resEngulfingShadow, i, price1, price2);
            }
         }
      }

   }
}



// Engulfing with Body
int isEngulfing(int pos)
{
   // return 0 : No detect engulfing
   // return 1 : bullish engulfing
   // return 2 : bearish engulfing

   bool bullish_pos = iClose(_Symbol,PERIOD_CURRENT,pos) > iOpen(_Symbol,PERIOD_CURRENT,pos);
   bool bearish_pos = iClose(_Symbol,PERIOD_CURRENT,pos) < iOpen(_Symbol,PERIOD_CURRENT,pos);
   bool even_pos = iClose(_Symbol,PERIOD_CURRENT,pos) == iOpen(_Symbol,PERIOD_CURRENT,pos);
   bool bullish_pre = iClose(_Symbol,PERIOD_CURRENT,pos+1) > iOpen(_Symbol,PERIOD_CURRENT,pos+1);
   bool bearish_pre = iClose(_Symbol,PERIOD_CURRENT,pos+1) < iOpen(_Symbol,PERIOD_CURRENT,pos+1);
   bool even_pre = iClose(_Symbol,PERIOD_CURRENT,pos+1) == iOpen(_Symbol,PERIOD_CURRENT,pos+1);

   int result = 0;


   // Bullish
   if ((bullish_pos && bearish_pre) || (bullish_pos && even_pre))  {
      if(iOpen(_Symbol,PERIOD_CURRENT,pos) <= iClose(_Symbol,PERIOD_CURRENT,pos+1) && iClose(_Symbol,PERIOD_CURRENT,pos) >= iOpen(_Symbol,PERIOD_CURRENT,pos+1))
      {
         result = 1;
      }
   }

   // Bearish
   if ((bearish_pos && bullish_pre) || (bearish_pos && even_pre))  {
      if(iOpen(_Symbol,PERIOD_CURRENT,pos) >= iClose(_Symbol,PERIOD_CURRENT,pos+1) && iClose(_Symbol,PERIOD_CURRENT,pos) <= iOpen(_Symbol,PERIOD_CURRENT,pos+1))  {
         result = 2;
      }
   }

   return result;
}

// Engulfing with Shadow
int isEngulfingShadow(int pos)
{
   // return 0 : No detect engulfing
   // return 1 : bullish engulfing
   // return 2 : bearish engulfing

   bool bullish_pos = iClose(_Symbol,PERIOD_CURRENT,pos) > iOpen(_Symbol,PERIOD_CURRENT,pos);
   bool bearish_pos = iClose(_Symbol,PERIOD_CURRENT,pos) < iOpen(_Symbol,PERIOD_CURRENT,pos);
   bool even_pos = iClose(_Symbol,PERIOD_CURRENT,pos) == iOpen(_Symbol,PERIOD_CURRENT,pos);
   bool bullish_pre = iClose(_Symbol,PERIOD_CURRENT,pos+1) > iOpen(_Symbol,PERIOD_CURRENT,pos+1);
   bool bearish_pre = iClose(_Symbol,PERIOD_CURRENT,pos+1) < iOpen(_Symbol,PERIOD_CURRENT,pos+1);
   bool even_pre = iClose(_Symbol,PERIOD_CURRENT,pos+1) == iOpen(_Symbol,PERIOD_CURRENT,pos+1);

   int result = 0;

   // Bullish
   if((bullish_pos && bearish_pre) || (bullish_pos && even_pre)) {
      if(iHigh(_Symbol,PERIOD_CURRENT,pos) >= iHigh(_Symbol,PERIOD_CURRENT,pos+1) && iLow(_Symbol,PERIOD_CURRENT,pos) <= iLow(_Symbol,PERIOD_CURRENT,pos+1)) {
         result = 1;
      }
   }

   // Bearish
   if((bearish_pos && bullish_pre) || (bearish_pos && even_pre))  {
      if(iHigh(_Symbol,PERIOD_CURRENT,pos) >= iHigh(_Symbol,PERIOD_CURRENT,pos+1) && iLow(_Symbol,PERIOD_CURRENT,pos) <= iLow(_Symbol,PERIOD_CURRENT,pos+1))  {
         result = 2;
      }
   }
   
   return result;
}

int isMarubozu(int pos)
{
   // return 0 : No detect engulfing
   // return 1 : bullish engulfing
   // return 2 : bearish engulfing
   bool bullish_pos = iClose(_Symbol,PERIOD_CURRENT,pos) > iOpen(_Symbol,PERIOD_CURRENT,pos);
   bool bearish_pos = iClose(_Symbol,PERIOD_CURRENT,pos) < iOpen(_Symbol,PERIOD_CURRENT,pos);
   bool even_pos = iClose(_Symbol,PERIOD_CURRENT,pos) == iOpen(_Symbol,PERIOD_CURRENT,pos);

   int result=0;
   double bodysize;
   
   // Bullish
   if (bullish_pos) {
      bodysize = ((iClose(_Symbol,PERIOD_CURRENT,pos) - iOpen(_Symbol,PERIOD_CURRENT,pos)) / (iHigh(_Symbol,PERIOD_CURRENT,pos) - iLow(_Symbol,PERIOD_CURRENT,pos))) * 100;
      if (bodysize >= inMarubozuPercent) {
         result = 1;
      }
   }
   
   if (bearish_pos) {
      bodysize = ((iOpen(_Symbol,PERIOD_CURRENT,pos) - iClose(_Symbol,PERIOD_CURRENT,pos)) / (iHigh(_Symbol,PERIOD_CURRENT,pos) - iLow(_Symbol,PERIOD_CURRENT,pos))) * 100;
      if (bodysize >= inMarubozuPercent) {
         result = 2;
      }
   }

   return result;
}



void createBox(string objName, int BullishBearish, int t1, double p1, double p2)
{

   if (t1 - inGuideBoxPeriod > 0) {
      ObjectCreate(0, objName, OBJ_RECTANGLE, 0, iTime(NULL, 0, t1), p1, iTime(NULL, 0, t1-inGuideBoxPeriod), p2);
   }
   else {
      ObjectCreate(0, objName, OBJ_RECTANGLE, 0, iTime(NULL, 0, t1), p1, iTime(NULL, 0, 0), p2);
   }
   
   ObjectSetInteger(0, objName, OBJPROP_FILL, InpFill);

   switch (BullishBearish) {
      case 1:
         ObjectSetInteger(0, objName, OBJPROP_COLOR, inBullishColour);
         break;

      case 2:
         ObjectSetInteger(0, objName, OBJPROP_COLOR, inBearishColour);
         break;
   }
}


void createBox161(string objName, int BullishBearish, int t1, double p1, double p2)
{

   if (t1 - inGuideBoxPeriod > 0) {
      ObjectCreate(0, objName, OBJ_RECTANGLE, 0, iTime(NULL, 0, t1+1), p1, iTime(NULL, 0, t1-inGuideBoxPeriod), p2);
   }
   else {
      ObjectCreate(0, objName, OBJ_RECTANGLE, 0, iTime(NULL, 0, t1+1), p1, iTime(NULL, 0, 0), p2);
   }

   ObjectSetInteger(0, objName, OBJPROP_STYLE, inBox161LineStyle);
   ObjectSetInteger(0, objName, OBJPROP_BACK, false);
//   ObjectSetInteger(0, objName, OBJPROP_FILL, InpFill);

   switch (BullishBearish) {
      case 1:
         ObjectSetInteger(0, objName, OBJPROP_COLOR, inBullishColour);
         break;

      case 2:
         ObjectSetInteger(0, objName, OBJPROP_COLOR, inBearishColour);
         break;
   }
}


void createHighlight(string objName, int BullishBearish, int t1, double p1, double p2)
{
   if (t1 > 0) {
      ObjectCreate(0, objName, OBJ_RECTANGLE, 0, iTime(NULL, 0, t1+1), p1, iTime(NULL, 0, t1-1), p2);
   }
   
   switch (BullishBearish) {
      case 1:
         ObjectSetInteger(0, objName, OBJPROP_COLOR, inBullishColour);
         break;

      case 2:
         ObjectSetInteger(0, objName, OBJPROP_COLOR, inBearishColour);
         break;
   }
}


void createHLine(string objName, int BullishBearish, int t1, double p1)
{

   ObjectCreate(0, objName, OBJ_HLINE, 0, t1, p1);
   ObjectSetInteger(0, objName, OBJPROP_WIDTH, inLineWidth);

   switch (BullishBearish) {
      case 1:
         ObjectSetInteger(0, objName, OBJPROP_COLOR, inBullishColour);
         break;

      case 2:
         ObjectSetInteger(0, objName, OBJPROP_COLOR, inBearishColour);
         break;
   }
}



double calcGuideprice(double p1, double p2, double ratio)
{
   double guidePrice;
   double temp;

   if (p1 > p2) {
      temp = p1 - p2;
      guidePrice = p1 - temp * ratio;
   }
   else {
      temp = p2 - p1;
      guidePrice = p1 + temp * ratio;
   }

   return guidePrice;
}


// Delete every drawing objects
void clearScreen()
{
   ObjectsDeleteAll(ChartID(), PrefixBox);
   ObjectsDeleteAll(ChartID(), PrefixBoxShadow);
   ObjectsDeleteAll(ChartID(), PrefixHighlight);
   ObjectsDeleteAll(ChartID(), PrefixHLine);
   ObjectsDeleteAll(ChartID(), PrefixBox161);
}


