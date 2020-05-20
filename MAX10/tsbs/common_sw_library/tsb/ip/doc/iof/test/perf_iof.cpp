/** Compare performance of iof functions/classes with sprintf, cout 
    and boost::format.
    
    To build with g++, use:
    
    g++ -o iof_perf -O -g -Wall -I ../include -I /c/Boost/include/boost-1_33_1 -DNDEBUG perf_iof.cpp

    or with VC++ use the perf.vcproj file (assumes boost in C:\Boost). 
    
    For VC++ 7.1 (on a 1.8GHz Dell Latitude D800 Pentium M), output is:

        Comparing performance for output:
        Time for sprintf format............:  5.7
        Time for std::cout format..........:  8.7
        Time for iof::fmtr.................: 10.5 (20%)
        Time for boost format..............: 17.5 (100%, 70%)
        
        Comparing performance for input:
        Time for raw input.................: 11.4
        Time for formatted input...........: 15.7 (40%)
        Time for formatted input w/error...: 25.6 (125%, 60%)

    For g++ v3.4.2 on the same system (using mingw):

		Comparing performance for output:
        Time for sprintf format............:  3.2
        Time for std::cout format..........: 11.4
        Time for iof::fmtr.................: 12.4 (10%)
        Time for boost format..............: 19.6 (70%, 60%)
        
        Comparing performance for input:
        Time for raw input.................: 27.1
        Time for formatted input...........: 32.0 (20%)
        Time for formatted input w/error...: 35.6 (30%, 10%)

    This means that all the power and convenience of iof::fmtr 
    comes with about 10-20% overhead for output, 20-40% overhead for 
    input (compared to direct use of STL manipulators). 
    Same output with boost::format has 5-7 times this overhead (!)
    (depending on compiler). 
     
    Copyright 2006 @ Oliver Schoenborn. This file is licensed 
    under BSD License.
    
    \author Oliver Schoenborn
    \version $Id: perf_iof.cpp 67 2006-05-21 04:33:08Z schoenborno $
*/

#include "iof/output.hpp"
#include <iostream>

#include <boost/format.hpp>
#include <boost/timer.hpp>
#include <iomanip>
#include <sstream>
#include <fstream>
#include <stdio.h>

static const char* boostFmt="%1$0#6x %2$20.10E %3$g %4$0+5d \n";
static const char* coutfFmt="%0#6xs %20.10Es %gs %+05s \n";
static const char* printfFmt="%0#6x %20.10E %g %+05d \n";
static const int        arg1=23;
static const double     arg2=45.23;
static const double     arg3=12.34;
static const std::string res = 
"0x0017    4.5230000000E+001 12.34 +0023 \n";

static const int nTests = 2*1000*500; // takes about 10 secs
static const char* resultFmt="%<35.s: %>4.1fs";

void testBoostFormat()
{
  using namespace std;
  std::ostringstream outTest;
  outTest << boost::format(boostFmt) % arg1 % arg2 % arg3 % arg1;
  if(outTest.str() != res )
    iof::cerrf("\nExpected\t'%s',\n\tgot\t'%s'\n", res, outTest.str());

  boost::format fmter;
  fmter.parse(boostFmt);
  boost::timer chrono;
  for (int i=0; i<nTests; ++i) 
  {
    std::ostringstream out;
    out << fmter % arg1 % arg2 % arg3 % arg1;
  }
  double t = chrono.elapsed();
  iof::coutf(resultFmt, "Time for boost format (pre-parsed)", t, iof::eol);
  
  chrono.restart();
  for (int i=0; i<nTests; ++i) 
  {
    std::ostringstream out;
    out << boost::format(boostFmt) % arg1 % arg2 % arg3 % arg1;
  }
  t = chrono.elapsed();
  iof::coutf(resultFmt, "Time for boost format (normal use)", t, iof::eol);
}


void testIofFormatter()
{
  using namespace std;
  std::ostringstream outTest;
  outTest << iof::fmtr(coutfFmt) & arg1 & arg2 & arg3 & arg1;
  if(outTest.str() != res )
    iof::cerrf("\nExpected\t'%s',\n\tgot\t'%s'\n", res, outTest.str());

  boost::timer chrono;
  for (int i=0; i<nTests; ++i) 
  {
    std::ostringstream out;
    out << iof::fmtr(coutfFmt) & arg1 & arg2 & arg3 & arg1;
  }
  double t = chrono.elapsed();
  iof::coutf(resultFmt, "Time for iof::fmtr", t, iof::eol);
}


void testIofToStr()
{
  using namespace std;
  std::string outTest = iof::tostr(coutfFmt, arg1, arg2, arg3, arg1);
  if(outTest != res )
    iof::cerrf("\nExpected\t'%s',\n\tgot\t'%s'\n", res, outTest);

  boost::timer chrono;
  for (int i=0; i<nTests; ++i) 
  {
    std::string outTest;
    outTest = iof::tostr(coutfFmt, arg1, arg2, arg3, arg1);
  }
  double t = chrono.elapsed();
  iof::coutf(resultFmt, "Time for iof::tostr", t, iof::eol);
}


void testPrintf()
{
    using namespace std;

    // Check that snpintf is Unix98 compatible on the platform :
    char * buf = new char[4000];
    sprintf(buf, printfFmt, arg1, arg2, arg3, arg1);
    if( strncmp( buf, res.c_str(), res.size()) != 0 )
        iof::cerrf("\nExpected\t'%s',\n\tgot\t'%s'\n", res, buf);

    // time the loop :
    boost::timer chrono;
    for (int i=0; i<nTests; ++i)
    {
        char * buf = new char[4000];
        sprintf(buf, printfFmt, arg1, arg2, arg3, arg1);
        delete[] buf;
    }
    
    double t = chrono.elapsed();
    iof::coutf(resultFmt, "Time for sprintf format", t, iof::eol);
}


void doStream(std::ostream& os)
{
    using namespace std;
    std::ios_base::fmtflags f = os.flags();
    
    //%0#6x %20.10E %g %+05d \n
    os << hex << showbase << internal << setfill('0') << setw(6) << arg1
       << dec << noshowbase << right << setfill(' ') 
       << " " 
       << scientific << setw(20) << setprecision(10) << uppercase << arg2 
       << setprecision(6) << nouppercase ;
    os.flags(f);
    os << " " << arg3 << " " 
       << showpos << setw(5) << internal << setfill('0') << arg1 << " \n" ;
    os.flags(f);
}


void testCout()
{
    using namespace std;
    std::ostringstream outTest;
    doStream(outTest);
    if(outTest.str() != res )
        iof::cerrf("\nExpected\t'%s',\n\tgot\t'%s'\n", res, outTest.str());

    boost::timer chrono;
    for (int i=0; i<nTests; ++i) 
    { 
        std::ostringstream out;
        doStream(out);
    }

    double t = chrono.elapsed();
    iof::coutf(resultFmt, "Time for std::cout format", t, iof::eol);
}

// ----------------------------------- INPUT testing -------------------

#include <cmath>


void testRawInput()
{
    int int_ = 0; 
    float float_ = 0;
    bool bool_ = false;
    std::string str_;
    
    boost::timer chrono;
    for (int i=0; i<4*nTests; ++i) 
    {
        std::istringstream inputs("abc123def -1.23abcde true...... hello ghi 456");
        inputs.ignore(3);
        inputs >> int_;
        inputs.ignore(3);
        inputs >> float_;
        inputs.ignore(100, 'e');
        inputs >> std::boolalpha >> bool_;
        inputs.ignore(100, ' ');
        inputs >> str_;
        inputs.ignore(4);
        inputs >> int_;
        assert(inputs);
    }
    double t = chrono.elapsed();
    iof::coutf(resultFmt, "Time for raw input", t, iof::eol);

    //iof::coutf("%s %s %s %s\n", int_, float_, bool_, str_, iof::eol);
    assert(int_ == 456);
    assert(fabs(float_ + 1.23) < 0.00001);
    assert(bool_);
    assert(str_=="hello");
}


void testIOFInput()
{
    int int_ = 0; 
    float float_ = 0;
    bool bool_ = false;
    std::string str_;
    
    boost::timer chrono;
    for (int i=0; i<4*nTests; ++i) 
    {
        std::istringstream inputs("abc123def -1.23abcde true...... hello ghi 456");
        inputs >> iof::fmtr("abc%sdef %s%[e]%as%[ ]%s ghi %s") 
               >> int_ >> float_ >> bool_ >> str_ >> int_;
        assert(inputs);
    }
    double t = chrono.elapsed();
    iof::coutf(resultFmt, "Time for formatted input", t, iof::eol);

    //iof::coutf("%s %s %s %s\n", int_, float_, bool_, str_, iof::eol);
    assert(int_ == 456);
    assert(fabs(float_ + 1.23) < 0.00001);
    assert(bool_);
    assert(str_=="hello");
}


/* Note that to be fair, the time taken by this routine should be 
   compared to a similar one as testRawInput() but where an exception
   is throw after the last arg is read, since it appears that throwing
   an exception has a significant cost. 
   */
void testIOFInputWithError()
{
    int int_ = 0; 
    float float_ = 0;
    bool bool_ = false;
    std::string str_;
        
    iof::validity okState;
    boost::timer chrono;
    for (int i=0; i<4*nTests; ++i) 
    {
        std::istringstream inputs("abc123def -1.23abcde true...... hello ghi 456");
        inputs >> iof::fmtr("abc%sdef %s%[e]%as%[ ]%s ghi %serr") 
               >> int_ >> float_ >> bool_ >> str_ >> int_ >> okState;
    }
    double t = chrono.elapsed();
    iof::coutf(resultFmt, "Time for formatted input w/error", t, iof::eol);
}


// --------------------------------- M A I N ----------------------

int main(int argc, char* argv[])
{
    if (argc <= 1)
    {
        iof::coutf("Comparing performance for output:", iof::eol);
        testPrintf();
        testCout();
        testIofFormatter();
        testIofToStr();
        testBoostFormat();
    }
    else 
    {
        iof::coutf("Comparing performance for input:", iof::eol);
        testRawInput();
        testIOFInput();
        testIOFInputWithError();
    }
}
