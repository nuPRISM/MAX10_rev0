/*
 * CBaseConverter.cpp
 *
 *  Created on: Aug 31, 2011
 *      Author: linnyair
 */

#include "CBaseConverter.h"
#include "basedef.h"
//#include "global_stream_defs.hpp"

bool CBaseConverter::NotifyIfInvalidBase()
       {
               if(!validBase)
               {
               	        safe_print(std::cout << "Invalid base (outside range 2-36) " << bcBase << ".\n");
                       return validBase;
               }

               return validBase;
       }

void CBaseConverter::ConstructSymbols()
{
        int i;
        char firstChar = static_cast<char>(digitStartInASCII);

        // Only fill baseSymbols with symbols that are going to be used
        // for conversion.

      //  out_to_all_streams("\nSymbols generated: ");

        for(i = 0; i < 10 && i < bcBase; i++)
        {
                baseSymbols[i] = firstChar + i;
//                out_to_all_streams(baseSymbols[i] << ' ');
        }

        firstChar = static_cast<char>(alphaStartInASCII);

        for(i = 10; i < 36 && i < bcBase; i++)
        {
                baseSymbols[i] = firstChar + (i - 10);
        //        out_to_all_streams(baseSymbols[i] << ' ');
        }

        //cout << '\n';
}

std::string CBaseConverter::ConvertToBase(unsigned long long decimalNum, int numdigits, int padleft, int enforce_maxdigits)
{
	std::string output_str;
	   bcBaseNVector = "";
        //cout << "CBaseConverter::ConvertToBase( Converting " << decimalNum << " to base " << bcBase << ").\n";
        if (enforce_maxdigits && ((numdigits < 0) || (numdigits > maxdigits)))
		{
        	safe_print(std::cout << "Error: CBaseConverter::ConvertToBase numdigits " << numdigits << "must be between 0 and " << maxdigits << "\n");
        	return "0";
		}
        int digit_count = 0;

        do  // Base conversion logic.
        {
        	   digit_count++;
               bcBaseNVector.push_back(baseSymbols[decimalNum % bcBase]);
               decimalNum /= bcBase;
        }
        while ((decimalNum && (enforce_maxdigits && (digit_count < numdigits))) || (decimalNum && (!enforce_maxdigits)));

        if (padleft && (digit_count < numdigits))
        {
          for (int i = digit_count; i < numdigits; i++)
          {
        	  bcBaseNVector.push_back('0');
          }
        }


        for(baseIter = bcBaseNVector.rbegin(); baseIter != bcBaseNVector.rend();  ++baseIter)
        	output_str.push_back(*baseIter);

        return output_str;
}

void CBaseConverter::PrintBaseConversion()
{
        if(!NotifyIfInvalidBase())
            return;

        safe_print(std::cout << "Base " << bcBase << " conversion ");

        for(baseIter = bcBaseNVector.rbegin(); baseIter != bcBaseNVector.rend();  ++baseIter)
            safe_print(std::cout << *baseIter);

        safe_print(std::cout << '\n');
}
