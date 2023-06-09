#property copyright                             "Copyright 2023, Shin Eun Gu"
#property link                                  "https://www.buymeacoffee.com/ss2299"
#property version                               "2.2"
#property indicator_chart_window                "Engulfing Candle detector"
#property description                           "Click the link to buy some coffee for us"
#property description                           "Your help would be making this indicator better"
#property description                           "https://www.buymeacoffee.com/ss2299"
#property strict

//--- input parameters
input    string             inGroupName1      = "-- Common Parameters --";              // Group_Common
input    bool               inEnableBody      = true;                                   // Engulfing with candle body
input    bool               inEnableShadow    = false;                                  // Engulfing with upper and lower shadow
input    int                inLookback        = 100;                                    // Lookback
input    color              inBullishColour   = clrLime;                                // Bullish colour
input    color              inBearishColour   = clrRed;                                 // Bearish colour
input    string             inBlank1          = "";                                     // .
input    string             inGroupName2      = "-- Highlight Candle Parameter --";     // Group_HighlightCandle
input    bool               inEnableHighlight = false;                                  // Enable highlight engulfing candle
input    string             inBlank2          = "";                                     // .
input    string             inGroupName3      = "-- Guide Price Line Parameters --";    // Group_GuideLine
input    bool               inEnableHLine     = false;                                  // Enable Hline drawing (50% of engulfing candle)
input    int                inLineWidth       = 1;                                      // Line width
input    string             inBlank3          = "";                                     // .
input    string             inGroupName4      = "-- Guide Price Box Parameters --";     // Group_GuideBox
input    bool               inEnableGuideBox  = true;                                   // Enable rectangle to guide price 1 and price 2
input    bool               inEnableBox161    = false;                                  // Enable rectangle with region of price 161.8
input    ENUM_LINE_STYLE    inBox161LineStyle = STYLE_DASH;                             // Line Style of Box 161
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
      if (LastActionTime != Time[1])  {
         displayEngulfing();
         LastActionTime = Time[1];
      }
   }  
}


void displayEngulfing()  {

   string str;
   double price1, price2;
   int bullishbearish;

   clearScreen();

   for (int i=0; i<inLookback; i++)  {
      bullishbearish = 0;
      if (inEnableBody)  {
         bullishbearish = isEngulfing(i, False);
         if (bullishbearish > 0) {
         
            if (inEnableGuideBox) {
               str = StringConcatenate(PrefixBox, i);
               price1 = calcGuideprice(Open[i], Close[i], inGuideBoxPrice1);
               price2 = calcGuideprice(Open[i], Close[i], inGuideBoxPrice2);
               createBox(str, bullishbearish, i, price1, price2);
            }
            

            // Highlight Box
            if (inEnableHighlight)  {
               str = StringConcatenate(PrefixHighlight, i);
               createHighlight(str, bullishbearish, i, Open[i], Close[i]);
            }

            // HLine
            if (inEnableHLine)  {
               str = StringConcatenate(PrefixHLine, i);
               price1 = calcGuideprice(Open[i], Close[i], 0.5);
               createHLine(str, bullishbearish, i, price1);
            }

            // Box161
            if (inEnableBox161)  {
               str = StringConcatenate(PrefixBox161, i);
               price1 = calcGuideprice(Open[i], Close[i], 0);
               price2 = calcGuideprice(Open[i], Close[i], 1.618);
               createBox161(str, bullishbearish, i, price1, price2);
            }
         }
      }

      bullishbearish = 0;
      if (inEnableShadow)  {
         bullishbearish = isEngulfing(i, True);
         if (bullishbearish > 0)  {
         
            if (inEnableGuideBox) {
               str = StringConcatenate(PrefixBox, i);
               ObjectDelete(str);
   
               str = StringConcatenate(PrefixBoxShadow, i);
               price1 = calcGuideprice(High[i], Low[i], inGuideBoxPrice1);
               price2 = calcGuideprice(High[i], Low[i], inGuideBoxPrice2);
               createBox(str, bullishbearish, i, price1, price2);
            }
            

            // Highlight Box
            if (inEnableHighlight)  {
               str = StringConcatenate(PrefixHighlight, i);
               ObjectDelete(str);   // Remove objects from detected by body

               str = StringConcatenate(PrefixHighlight, i);
               createHighlight(str, bullishbearish, i, High[i], Low[i]);
            }

            // HLine
            if (inEnableHLine)  {
               str = StringConcatenate(PrefixHLine, i);
               ObjectDelete(str);   // Remove objects from detected by body

               price1 = calcGuideprice(High[i], Low[i], 0.5);
               createHLine(str, bullishbearish, i, price1);
            }

            // Box161
            if (inEnableBox161)  {
               str = StringConcatenate(PrefixBox161, i);
               ObjectDelete(str);   // Remove objects from detected by body

               price1 = calcGuideprice(High[i], Low[i], 0);
               price2 = calcGuideprice(High[i], Low[i], 1.618);
               createBox161(str, bullishbearish, i, price1, price2);
            }
         }
      }

   }
}



int isEngulfing(int pos, bool shadow)
{
// return 0 : No detect engulfing
// return 1 : bullish engulfing
// return 2 : bearish engulfing

   bool bullish_pos = Close[pos] > Open[pos];
   bool bearish_pos = Close[pos] < Open[pos];
   bool even_pos = Close[pos] == Open[pos];
   bool bullish_pre = Close[pos+1] > Open[pos+1];
   bool bearish_pre = Close[pos+1] < Open[pos+1];
   bool even_pre = Close[pos+1] == Open[pos+1];

   int result = 0;

   if (shadow) {

      // Bullish Candle with the shadow
      if((bullish_pos && bearish_pre) || (bullish_pos && even_pre)) {
         if(High[pos] >= High[pos+1] && Low[pos] <= Low[pos+1]) {
            result = 1;
         }
      }

      // Bearish Candle with the shadow
      if((bearish_pos && bullish_pre) || (bearish_pos && even_pre))  {
         if(High[pos] >= High[pos+1] && Low[pos] <= Low[pos+1])  {
            result = 2;
         }
      }
   }

   if (!shadow)  {
      // Bullish Candle without the shadow
      if ((bullish_pos && bearish_pre) || (bullish_pos && even_pre))  {
         if(Open[pos] <= Close[pos+1] && Close[pos] >= Open[pos+1])
         {
            result = 1;
         }
      }

      // Bearish Candle without the shadow
      if ((bearish_pos && bullish_pre) || (bearish_pos && even_pre))  {
         if(Open[pos] >= Close[pos+1] && Close[pos] <= Open[pos+1])  {
            result = 2;
         }
      }
   }

   return result;
}



void createBox(string objName, int BullishBearish, int t1, double p1, double p2)
{

   if (t1 - inGuideBoxPeriod > 0) {
      ObjectCreate(objName, OBJ_RECTANGLE, 0, Time[t1], p1, Time[t1-inGuideBoxPeriod], p2);
   }
   else {
      ObjectCreate(objName, OBJ_RECTANGLE, 0, Time[t1], p1, Time[0], p2);
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


void createBox161(string objName, int BullishBearish, int t1, double p1, double p2)
{

   if (t1 - inGuideBoxPeriod > 0) {
      ObjectCreate(objName, OBJ_RECTANGLE, 0, Time[t1+1], p1, Time[t1-inGuideBoxPeriod], p2);
   }
   else {
      ObjectCreate(objName, OBJ_RECTANGLE, 0, Time[t1+1], p1, Time[0], p2);
   }

   ObjectSetInteger(0, objName, OBJPROP_STYLE, inBox161LineStyle);
   ObjectSetInteger(0, objName, OBJPROP_BACK, False);

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
      ObjectCreate(objName, OBJ_RECTANGLE, 0, Time[t1+1], p1, Time[t1-1], p2);
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

   ObjectCreate(objName, OBJ_HLINE, 0, t1, p1);
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

