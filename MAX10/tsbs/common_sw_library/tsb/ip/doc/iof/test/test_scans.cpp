#include <math.h>
#include <string>
#include <boost/test/auto_unit_test.hpp>
#include <boost/test/floating_point_comparison.hpp>

#include "iof/scans.hpp"
using namespace iof;
#include "test_foo.hpp"


BOOST_AUTO_TEST_SUITE( suiteScans );

BOOST_AUTO_TEST_CASE( testFmtrIn )
{
    // input with fmtr
    std::istringstream input("hi 123 true 1\n");
    std::string hi; 
    int int1 = 0;
    bool bool1 = false, bool2 = false;
    BOOST_CHECK(input >> fmtr("%s%s%as%s\n") >> hi >> int1 >> bool1 >> bool2);
    BOOST_CHECK_EQUAL(hi, "hi");
    BOOST_CHECK_EQUAL(int1, 123);
    BOOST_CHECK(bool1);
    BOOST_CHECK(bool2);
}


BOOST_AUTO_TEST_CASE( testFmtrSkip )
{
    // input with fmtr, skip to end of line and end of stream
    std::istringstream input2("12 34 56\n987 543 321\n368 asd fasdf\n");
    std::string hi; 
    int int1 = 0, int2 = 0, int3 = 0;
    //input2 >> fmtr("%(>>2>)%s%(10\n> >)%s%(\n>)%s") >> int1 >> int2 >> int3;
    input2 >> fmtr("%[>>2>]%s%[10\n> >]%s%[\n>]%s") >> int1 >> int2 >> int3;
    BOOST_CHECK(input2);
    BOOST_CHECK_MESSAGE(int1 == 4, int1);
    BOOST_CHECK_MESSAGE(int2 == 543, int2);
    BOOST_CHECK_MESSAGE(int3 == 368, int3);

    // another such test, using instance of class iof::skip_past
    std::istringstream input3("1234 abc 123\n45abc");
    input3 >> fmtr("%s%s %s%sab") & skip_past(2) & int1 & skip_past("\n") & int2;
    BOOST_CHECK_EQUAL(int1, 34);
    BOOST_CHECK_EQUAL(int2, 45);
    input3 >> hi;
    BOOST_CHECK_EQUAL(hi, "c");    
}


BOOST_AUTO_TEST_CASE( testIn1Fmt )
{
    // simple parse
    std::istringstream msg("hello hiho");
    std::string result; 
    const char* fmt = "hel%s hi%s";
    iof_private::fmtr_in fout(msg, fmt);
    BOOST_REQUIRE(fout.pos() >= 0);
    fout >> result;
    BOOST_CHECK_EQUAL(fout.pos(), 9);
    BOOST_CHECK_EQUAL(result, "lo");
    fout >> result;
    BOOST_CHECK(fout.pos() < 0);
    BOOST_CHECK_EQUAL(result, "ho");
}


// Test prints with whole bunch of formats
BOOST_AUTO_TEST_CASE( testScanSimple )
{
    // test simple
    std::istringstream input("hello");
    std::string result;
    scans(input, result);
    BOOST_CHECK_EQUAL(result, "hello");
}


BOOST_AUTO_TEST_CASE( testScanTwoInOne )
{
    // test double
    std::string name, salut;
    std::istringstream input("yo hello joe");
    scans(input, "yo %s%s", salut, name);
    BOOST_CHECK_EQUAL(salut, "hello");
    BOOST_CHECK_EQUAL(name, "joe");
}


BOOST_AUTO_TEST_CASE( testScanTwoInTwo )
{
    // test two inputs on one stream in two separate calls
    std::istringstream input("hello joe");
    std::string name, salut;
    scans(input, "%s", salut);
    scans(input, "%s", name);
    BOOST_CHECK_EQUAL(salut, "hello");
    BOOST_CHECK_EQUAL(name, "joe");
}


BOOST_AUTO_TEST_CASE( testScanLeftoverChars )
{
    // test left over stuff
    std::istringstream input("hello joe");
    std::string name, salut;
    scans(input, "%s jo", salut);
    scans(input, "%s", name);
    BOOST_CHECK_EQUAL(salut, "hello");
    BOOST_CHECK_EQUAL(name, "e");
}


BOOST_AUTO_TEST_CASE( testScanLeftoverMakers )
{
    // test when left over markers
    std::istringstream input("hello joe");
    std::string name, salut;
    scans(input, "", salut, name);
    BOOST_CHECK_EQUAL(salut, "hello");
    BOOST_CHECK_EQUAL(name, "joe");
}


BOOST_AUTO_TEST_CASE( testScanPOD )
{
    // input whole bunch of POD types; init vars so sure they were set by input
    int int1 = 0;
    float pi = 0;
    char c1=0, c2=0;
    bool bool1=false, bool2=true;
    std::string result;
    std::istringstream input("hello 123   bc true false 0 1 3.1416");
    scans(input, "%s%s", result, int1);
    BOOST_CHECK_EQUAL(result, "hello");
    BOOST_CHECK_EQUAL(int1, 123);
    scans(input, "%s%s", c1, c2);
    BOOST_CHECK_EQUAL(c1, 'b');
    BOOST_CHECK_EQUAL(c2, 'c');
    scans(input, "%as%as", bool1, bool2);
    BOOST_CHECK(bool1);
    BOOST_CHECK(!bool2);
    scans(input, "%s%s",   bool1, bool2);
    BOOST_CHECK(!bool1);
    BOOST_CHECK(bool2);
    scans(input, pi);
    BOOST_CHECK_CLOSE(pi, 3.1416f, 0.000001f);
}


BOOST_AUTO_TEST_CASE( testScanWidth )
{
    // test width
    std::istringstream input("1234567890");
    std::string result, name;
    scans(input, "%3s%s", result, name);
    BOOST_CHECK_EQUAL(result, "123");
    BOOST_CHECK_EQUAL(name, "4567890");
}


BOOST_AUTO_TEST_CASE( testScanPersistence )
{
    // test persistence
    bool bool1=false, bool2=false;
    std::istringstream input("true true 0 1234567890123");
    scans(input, "%aS%s", bool1, bool2);
    BOOST_CHECK(bool1);
    BOOST_CHECK(bool2);
    scans(input, "%s", bool1);
    BOOST_CHECK(!bool1);
    std::string result, name;
    scans(input, "%4S%s", result, name);
    BOOST_CHECK_EQUAL(result, "1234");
    BOOST_CHECK_EQUAL(name, "5678");
    scans(input, "%s", result);
    BOOST_CHECK_EQUAL(result, "90123");
}


BOOST_AUTO_TEST_CASE( testScanNoSkipWithPersist )
{
    // test no-skip of whitespace, with persistence
    char c1=0, c2=0;
    char c3=0, c4=0;
    std::istringstream input(" a b");
    scans(input, "%~S%s", c1,c2);
    scans(input, "%~S%s", c3,c4);
    BOOST_CHECK_EQUAL(c1, ' ');
    BOOST_CHECK_EQUAL(c2, 'a');
    BOOST_CHECK_EQUAL(c3, ' ');
    BOOST_CHECK_EQUAL(c4, 'b');
}


BOOST_AUTO_TEST_CASE( testFillIn ) 
{
    std::istringstream input(".....abc _____123");
    std::string str;
    int int1;
    input >> iof::fmtr("%.s %_s") >> str >> int1;
    BOOST_CHECK_EQUAL(str, "abc");
    BOOST_CHECK_EQUAL(int1, 123);
    
    // test escape of fill
    std::istringstream input2(".....abc_...def_... mmmmab_");
    std::string str1, str2, str3, str4;
    input2 >> iof::fmtr("%!..._S_%s_% .. S %ms") >> str1 >> str2 >> str3 >> str4;
    BOOST_CHECK_EQUAL(str1, "abc");
    BOOST_CHECK_EQUAL(str2, "def");
    BOOST_CHECK_EQUAL(str3, "...");
    BOOST_CHECK_EQUAL(str4, "ab_");
}


BOOST_AUTO_TEST_CASE( testDelimIn ) 
{
    std::istringstream input("abcdefghijk=lmnop=qrs  tuv=wxy=zz a=b");
    char b;
    std::string str;
    input >> iof::fmtr("a%s%..fsf") >> b >> str;
    BOOST_CHECK_EQUAL(b, 'b');
    BOOST_CHECK_EQUAL(str, "cde");
    
    std::string str2;
    input >> iof::fmtr("%..=s=%s") >> str >> str2;
    BOOST_CHECK_EQUAL(str , "ghijk");
    BOOST_CHECK_EQUAL(str2, "lmnop=qrs");
    
    std::string str3, str4;
    input >> iof::fmtr("%..=S=%s=%.. s %s=b") >> str >> str2 >> str3 >> str4;
    BOOST_CHECK_EQUAL(str, "  tuv");
    BOOST_CHECK_EQUAL(str2, "wxy");
    BOOST_CHECK_EQUAL(str3, "zz");
    BOOST_CHECK_EQUAL(str4, "a");
}


BOOST_AUTO_TEST_CASE( testDelimFmtSpecIn ) 
{
    std::istringstream input("123...456... 789...123...456(789)");
    
    // get string till next dot:
    iof::fmt_spec fs("...");
    std::string str, str2;
    input >> iof::fmtr("%s%.s") >> fs >> str >> str2;
    BOOST_CHECK_EQUAL(str, "123");
    BOOST_CHECK_EQUAL(str2, "456...");
    
    // use some persistence:
    str = str2 = "";
    std::string str3, str4;
    iof::fmt_spec fs2("..(");
    input >> iof::fmtr("%.S%s%S(%..)s)") >> fs >> str >> str2 >> fs2 >> str3 >> str4;
    BOOST_CHECK_EQUAL(str , " 789");
    BOOST_CHECK_EQUAL(str2, "123");
    BOOST_CHECK_EQUAL(str3, "456");
    BOOST_CHECK_EQUAL(str4, "789");
}


BOOST_AUTO_TEST_CASE( testFmtSpecIn )
{
    std::istringstream input("abc");
    iof::fmt_spec fs("");
    char b;
    input >> iof::fmtr("a%sc") >> fs >> b;
    BOOST_CHECK_EQUAL(b, 'b');
}


BOOST_AUTO_TEST_CASE( testScanExcept )
{
    using namespace iof_private;
    std::istringstream input;
    BOOST_CHECK_EQUAL( bool(fmtr_in(input, "")), bool(input) );
    
    input.str("abc");
    int int1 = 0;
    BOOST_CHECK_THROW(fmtr_in(input, "%") >> int1,      marker_not_closed_fmt);
    BOOST_CHECK_THROW(fmtr_in(input, "a%.2fb") >> int1, marker_not_closed_fmt);
    BOOST_CHECK_THROW(fmtr_in(input, "%["),             marker_not_closed_skip);
    BOOST_CHECK_THROW(fmtr_in(input, "%s"),             too_many_markers);
}


BOOST_AUTO_TEST_CASE( testBadInput )
{
    using namespace iof_private;

    // test usual "while" loop 
    {
        std::istringstream input("123abc456 321cbaNUM");
        int count=0, int1=0, int2=0;
        std::string abc;
        while (input >> fmtr("%s%3s%s") >> int1 >> abc >> int2)
            count++;
        BOOST_CHECK_EQUAL(count, 1);
        BOOST_CHECK_EQUAL(int1, 321);
        BOOST_CHECK_EQUAL(int2, 456);
        BOOST_CHECK_EQUAL(abc, "cba");
    }

    // test "while" loop with validity obj, problem pos in middle
    {
        std::istringstream input("123abc456 321cba654 NUM");
        int count=0, int1=0, int2=0;
        std::string abc;
        validity ok;
        while (input >> fmtr("%s%3s%s") >> int1 >> abc >> int2 >> ok)
            count++;
        BOOST_CHECK_EQUAL(count, 2);
        BOOST_CHECK_EQUAL(int1, 321);
        BOOST_CHECK_EQUAL(int2, 654);
        BOOST_CHECK_EQUAL(abc, "cba");
        BOOST_CHECK_EQUAL(ok, false);
        BOOST_CHECK_EQUAL(ok.problemPos, 1);
        BOOST_CHECK_EQUAL(ok.fmt, "%s%3s%s");
    }

    // test "while" loop with validity obj, problem pos last
    {
        std::istringstream input("123abc456 321cba654 NUM");
        int count=0, int1=0, int2=0;
        std::string abc;
        validity ok;
        while (input >> fmtr("%s%2s%s") >> int1 >> abc >> int2 >> ok)
            count++;
        BOOST_CHECK_EQUAL(count, 0);
        BOOST_CHECK_EQUAL(int1, 123);
        BOOST_CHECK_EQUAL(int2, 0);
        BOOST_CHECK_EQUAL(abc, "ab");
        BOOST_CHECK_EQUAL(ok, false);
        BOOST_CHECK_EQUAL(size_t(ok.problemPos), ok.fmt.size()-1);
    }

    // test "while" loop with validity obj, problem pos past last
    {
        std::istringstream input("123 NUM");
        int count=0, int1=0, int2=0;
        validity ok;
        while (input >> fmtr("%s") >> int1 >> int2 >> ok)
            count++;
        BOOST_CHECK_EQUAL(count, 0);
        BOOST_CHECK_EQUAL(int1, 123);
        BOOST_CHECK_EQUAL(int2, 0);
        BOOST_CHECK_EQUAL(ok, false);
        BOOST_CHECK_EQUAL(size_t(ok.problemPos), ok.fmt.size());
    }
}

    
BOOST_AUTO_TEST_SUITE_END();
