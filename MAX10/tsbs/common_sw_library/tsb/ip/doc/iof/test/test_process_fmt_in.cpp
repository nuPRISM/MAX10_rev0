/** Unit testing for process_* files. Uses the Boost unit testing framework.
    
    Copyright 2006 @ Oliver Schoenborn. This file is licensed under BSD License.
    
    \author Oliver Schoenborn
    \version $Id: test_process_fmt_in.cpp 68 2006-05-21 06:13:23Z schoenborno $
*/

#include <boost/test/auto_unit_test.hpp>
#include <iostream>

#include "iof/process_fmt_in.hpp"
using namespace iof;
#include "test_foo.hpp"


BOOST_AUTO_TEST_SUITE( suiteProcessFmtIn );

// test consume(std:istream)
BOOST_AUTO_TEST_CASE( testSkip )
{
    // skipping of empty (one character)
    std::istringstream input("1,2ab9 - 3,4 - 5,6 > 7 ) 8 ! 9");
    input.exceptions(std::ios::failbit | std::ios::badbit);
    const char* fmt = "]";
    const char* newFmt = iof_private::doSkip(input, fmt);
    BOOST_CHECK_EQUAL(newFmt, fmt+1);
    iof_private::doSkip(input, fmt); // skip another char
    int int1 = 0;
    input >> int1;
    BOOST_CHECK_EQUAL(int1, 2);
    
    // skip by >: 
    fmt = ">>]";
    iof_private::doSkip(input, fmt); // skip another char
    int1 = 0;
    input >> int1;
    BOOST_CHECK_EQUAL(int1, 9);
    
    // skip N chars
    fmt = "3]";
    iof_private::doSkip(input, fmt); // skip another char
    int1 = 0;
    input >> int1;
    BOOST_CHECK_EQUAL(int1, 3);
    
    // skip past next given char
    fmt = "-]";
    iof_private::doSkip(input, fmt); // skip another char
    int1 = 0;
    input >> int1;
    BOOST_CHECK_EQUAL(int1, 5);
    
    // skip past an escaped char
    fmt = "!>]";
    iof_private::doSkip(input, fmt); // skip another char
    int1 = 0;
    input >> int1;
    BOOST_CHECK_EQUAL(int1, 7);
    fmt = "!)]";
    iof_private::doSkip(input, fmt); // skip another char
    int1 = 0;
    input >> int1;
    BOOST_CHECK_EQUAL(int1, 8);
    fmt = "!!]";
    fmt = iof_private::doSkip(input, fmt); // skip another char
    BOOST_CHECK_EQUAL(*fmt, 0);
    int1 = 0;
    input >> int1;
    BOOST_CHECK_EQUAL(int1, 9);
    
    // several skips with "infinites"
    std::istringstream input2("123,0 - 56, 78; 89; 90; 100; abcdef 1");
    fmt = "0!0>,>0;>>>]";
    iof_private::doSkip(input2, fmt); // skip another char
    int1 = 0;
    input2 >> int1;
    BOOST_CHECK(input2);
    BOOST_CHECK_EQUAL(int1, 100);
    iof_private::doSkip(input2, "0]"); // skip another char
    int1 = 0;
    input2 >> int1;
    BOOST_CHECK(!input2);
    BOOST_CHECK_EQUAL(int1, 0);
    
}


// Test processToNextFmtMarker() for input for cases where it is expected to return NULL
std::string testProcToNextFmtMarkerInReturnsNULL(const char* input, const char* fmt)
{
    std::istringstream grab(input);
    grab.exceptions(std::ios::failbit | std::ios::badbit);
    const char* newFmt = iof_private::processToNextFmtMarker(grab, fmt);
    BOOST_CHECK_EQUAL( newFmt, (const char*)NULL );
    
    // put what's left in stream (next word at least) into a string
    std::string result;
    try {grab >> result;}
    catch (const std::ios::failure&)
    {
        if (!grab.eof()) throw;
    }
    
    return result;
}


// Test processToNextFmtMarker() for output for cases where it is expected 
// to return non-NULL, compare return value to msg+expect
std::string testProcToNextFmtMarkerInRetNonNULL(const char* msg, int expect)
{
    std::istringstream grab(msg);
    grab.exceptions(std::ios::failbit | std::ios::badbit);
    const char* found = iof_private::processToNextFmtMarker(grab, msg);
    BOOST_CHECK_MESSAGE( found == (msg+expect),
        "marker test got " << size_t(found-msg) << ", expected " << expect );
    std::string result;
    grab >> result;
    return result;
}


void testProcToNextFmtMarkerInExcept(const char* input, const char* fmt, 
    iof_private::failure::err_type probType, int expectProblem)
{
    std::istringstream grab(input);
    try {
        iof_private::processToNextFmtMarker(grab, fmt);
    }
    catch (const iof_private::failure& fail)
    {
        BOOST_CHECK_EQUAL(fail.problem, fmt+expectProblem);
        BOOST_CHECK_EQUAL(fail.errType, probType);
        throw;
    }
}


// test basic case for input stream
BOOST_AUTO_TEST_CASE( testProcToNextFmtMarkerIn )
{
    // test when things go wrong:
    // read more than available: 
    BOOST_CHECK_THROW( testProcToNextFmtMarkerInExcept("abc", "abcd", 
        iof_private::failure::IO_FAILURE, 3), iof_private::failure);
    // read wrong char
    BOOST_CHECK_THROW( testProcToNextFmtMarkerInExcept("abc", "abd", 
        iof_private::failure::IO_FAILURE, 2), iof_private::failure);
    // skipping marker not closed
    BOOST_CHECK_THROW( testProcToNextFmtMarkerInExcept("abc", "%[20", 
        iof_private::failure::MARKER_NOT_CLOSED, 2), iof_private::failure);
    BOOST_CHECK_THROW( testProcToNextFmtMarkerInExcept("abc", "%[!]", 
        iof_private::failure::MARKER_NOT_CLOSED, 2), iof_private::failure);
    // exec skipping after end of stream reached
    BOOST_CHECK_THROW( testProcToNextFmtMarkerInExcept("abc", "%[5]%[]", 
        iof_private::failure::IO_FAILURE, 6), iof_private::failure);
    BOOST_CHECK_THROW( testProcToNextFmtMarkerInExcept("abc", "%[5>1>]", 
        iof_private::failure::IO_FAILURE, 5), iof_private::failure);

    // cases that should return NULL
    BOOST_CHECK_EQUAL( testProcToNextFmtMarkerInReturnsNULL("abc", "")             , "abc" );
    BOOST_CHECK_EQUAL( testProcToNextFmtMarkerInReturnsNULL("abcdef", "abc")       , "def" );
    BOOST_CHECK_EQUAL( testProcToNextFmtMarkerInReturnsNULL("abc%def", "abc%%")    , "def" );
    BOOST_CHECK_EQUAL( testProcToNextFmtMarkerInReturnsNULL("ab%de%gh", "ab%%de%%g"), "h" );
    BOOST_CHECK_EQUAL( testProcToNextFmtMarkerInReturnsNULL("abc", "abc")          , "" );
    // also skipping:
    BOOST_CHECK_EQUAL( testProcToNextFmtMarkerInReturnsNULL("abcdef%%gh", "ab%[f]%%")  , "%gh" );
    BOOST_CHECK_EQUAL( testProcToNextFmtMarkerInReturnsNULL("abcdef%%gh", "ab%[4]%%")  , "%gh" );
    BOOST_CHECK_EQUAL( testProcToNextFmtMarkerInReturnsNULL("abcdef%%gh", "ab%[10f]%%"), "%gh" );

    // cases that should point to a format marker (%)
    BOOST_CHECK_EQUAL( testProcToNextFmtMarkerInRetNonNULL("%s abc", 1), "%s");
    BOOST_CHECK_EQUAL( testProcToNextFmtMarkerInRetNonNULL("efg %s abc", 5), "%s");
    BOOST_CHECK_EQUAL( testProcToNextFmtMarkerInRetNonNULL("abc%[f]]%z abc", 9), "]%z");
    BOOST_CHECK_EQUAL( testProcToNextFmtMarkerInRetNonNULL("abc%", 4), "%" );
}


//====================================================
template <typename TT>
const TT& testProc1FmtSpecIn(const char* input, const char* fmt, TT& obj, int expectRet = 0)
{
    std::istringstream grab(input);
    bool restoreFmt; // not used
    char delim = 0; // not used
    const char* next = iof_private::processToNextFmtMarker(grab, fmt);
    const char* result = iof_private::process1FmtSpec(grab, next, restoreFmt, delim);
    if (expectRet == 0)
        BOOST_CHECK_MESSAGE(result == NULL, "error: " << fmt );
    else
        BOOST_CHECK_MESSAGE(result == (fmt+expectRet), 
            "expect, error: " << expectRet << ", " << result-fmt << ", " << fmt );
    grab >> obj;
    return obj;
}


void testMarkerNotClosedIn(const char* fmt)
{
    std::istringstream grab;
    bool restoreFmt; // not used
    char delim; // not used
    try {
        iof_private::process1FmtSpec(grab, fmt, restoreFmt, delim);
    }
    catch (const iof_private::failure& fail)
    {
        BOOST_CHECK_EQUAL(fail.problem, fmt);
        BOOST_CHECK_EQUAL(fail.errType, iof_private::failure::MARKER_NOT_CLOSED);
        throw;
    }
}


BOOST_AUTO_TEST_CASE( testAllProc1FmtSpecIn )
{
    std::string remain;
    BOOST_CHECK_EQUAL( testProc1FmtSpecIn("hello", "", remain)      , "hello" );
    BOOST_CHECK_EQUAL( testProc1FmtSpecIn("hello", "hel", remain)   , "lo" );
    BOOST_CHECK_EQUAL( testProc1FmtSpecIn("hello bb", "hel", remain), "lo" );
    BOOST_CHECK_EQUAL( testProc1FmtSpecIn("hello", "%s", remain)    , "hello" );
    BOOST_CHECK_EQUAL( testProc1FmtSpecIn("hello", "hel%s", remain) , "lo" );
    BOOST_CHECK_EQUAL( testProc1FmtSpecIn("hello", "%3s", remain)   , "hel");
    BOOST_CHECK_EQUAL( testProc1FmtSpecIn("goodbye", "goo%s+++", remain, 5), "dbye" );
    
    int integ;
    BOOST_CHECK_EQUAL( testProc1FmtSpecIn("123", "1%s", integ), 23 );
    BOOST_CHECK_EQUAL( testProc1FmtSpecIn("11", "%s", integ)  , 11);
    BOOST_CHECK_EQUAL( testProc1FmtSpecIn("11", "%xs", integ) , 17);
    BOOST_CHECK_EQUAL( testProc1FmtSpecIn("11", "%os", integ) , 9);
    
    bool boolean;
    BOOST_CHECK_EQUAL( testProc1FmtSpecIn("0",     "%s",  boolean), false);
    BOOST_CHECK_EQUAL( testProc1FmtSpecIn("1",     "%s",  boolean), true);
    BOOST_CHECK_EQUAL( testProc1FmtSpecIn("true",  "%as", boolean), true);
    BOOST_CHECK_EQUAL( testProc1FmtSpecIn("false", "%as", boolean), false);
    
    char aChar;
    BOOST_CHECK_EQUAL( testProc1FmtSpecIn("   abc", "%~s", aChar), ' ');
    BOOST_CHECK_EQUAL( testProc1FmtSpecIn("   abc", "%s",  aChar), 'a');
    
    Foo foo; 
    BOOST_CHECK_EQUAL( testProc1FmtSpecIn("987, 654", "%s", foo), Foo(987, 654) );
    
    BOOST_CHECK_EQUAL( testProc1FmtSpecIn("123 456", "%[>>]%s", integ), 3 );
    
    // test exception when marker not closed
    BOOST_CHECK_THROW( testMarkerNotClosedIn(""), iof_private::failure); // top
    BOOST_CHECK_THROW( testMarkerNotClosedIn("!"), iof_private::failure); // bad escape
    BOOST_CHECK_THROW( testMarkerNotClosedIn(".2f"), iof_private::failure); // bottom
        
}

    
BOOST_AUTO_TEST_SUITE_END();

