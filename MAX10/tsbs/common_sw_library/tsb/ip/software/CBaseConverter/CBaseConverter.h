/*
 * CBaseConverter.h
 *
 *  Created on: Aug 31, 2011
 *      Author: linnyair
 */

#ifndef CBASECONVERTER_H_
#define CBASECONVERTER_H_

#include <iostream>
#include <vector>
#include <map>


class CBaseConverter
{

protected:

        int bcBase;
        bool validBase;
        void ConstructSymbols();

        static const int minBase  = 2;
        static const int maxBase = 36;
        static const int maxdigits = 100;

        static const int digitStartInASCII  = 0x30;         // '0'
        static const int alphaStartInASCII = 0x61;       // 'a'

        // Reference vector to pass proper symbol to bcBaseNVector.
        // examples: map<0, '0'> and map<10, 'a'>.
        std::map<int, char> baseSymbols;

        // Stores the number in its new base.
        std::string bcBaseNVector;
        std::string::reverse_iterator baseIter;
public:

        CBaseConverter(int base) :  bcBase(base)
        {
                if(bcBase < minBase || bcBase > maxBase)
                        validBase = false;
                else
                        validBase = true;
                if(!NotifyIfInvalidBase())
                           return;

                ConstructSymbols();
        }
        ~CBaseConverter(){}

        bool NotifyIfInvalidBase();

        std::string ConvertToBase(unsigned long long decimalNum, int numdigits, int padleft, int enforce_maxdigits);
        void PrintBaseConversion();

};
#endif /* CBASECONVERTER_H_ */
