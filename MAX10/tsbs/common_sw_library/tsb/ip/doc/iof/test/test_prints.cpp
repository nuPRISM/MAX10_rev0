#include <iostream>
#include <boost/test/auto_unit_test.hpp>
#include "iof/fmt_guard.hpp"
#include "iof/prints.hpp"
#include "iof/omanips.hpp"
using namespace iof;
#include "test_foo.hpp"


BOOST_AUTO_TEST_SUITE( suitePrints );

BOOST_AUTO_TEST_CASE( testTruncation )
{
    {
        std::ostringstream msg;
        msg << iof::fmtr("%s") << "1234567890";
        BOOST_CHECK_EQUAL(msg.str(), "1234567890");
    }
    
    {
        std::ostringstream msg;
        msg << iof::fmtr("%@5s") << std::string("abcdefghij");
        BOOST_CHECK_EQUAL(msg.str(), "abcde");
    }
    
    {
        std::ostringstream msg;
        const char* buf = "klmnopqrst";
        msg << iof::fmtr("%@5s") << buf;
        BOOST_CHECK_EQUAL(msg.str(), "klmno");
    }
    
    {
        std::ostringstream msg;
        const char buf[] = "uvwxyzabcd";
        msg << iof::fmtr("%@5s") << buf;
        BOOST_CHECK_EQUAL(msg.str(), "uvwxy");
    }
    
    {
        Foo foo; 
        std::ostringstream msg;
        msg << iof::fmtr("%=10@6s") << foo;
        BOOST_CHECK_EQUAL(msg.str(), "  543, 9  ");
    }    
}


// Test prints with whole bunch of formats
BOOST_AUTO_TEST_CASE( testPrint )
{
    Foo foo;
    // need clean stream for every test
    std::auto_ptr<std::ostringstream> output;

    // test simple
    output.reset( new std::ostringstream);
    prints(*output, "Hi\n");
    BOOST_CHECK_EQUAL(output->str(), "Hi\n");

    // test with one arg
    output.reset( new std::ostringstream);
    BOOST_CHECK( prints(*output, "Foo is: %s", foo) );
    BOOST_CHECK_EQUAL(output->str(), "Foo is: 543, 987");

    // test with no %s (append only) and EOL
    output.reset( new std::ostringstream);
    prints(*output, "Foo is: ", foo, eol);
    BOOST_CHECK_EQUAL(output->str(), "Foo is: 543, 987\n");

    // test int, fill and unused fmt
    output.reset( new std::ostringstream);
    prints(*output, "Int is: %5*s, but not 321!!\n", 123);
    BOOST_CHECK_EQUAL(output->str(), "Int is: **123, but not 321!!\n");

    // test boolalpha, UDT and flush
    output.reset( new std::ostringstream);
    prints(*output, "Bool is: %as, but not %s\n", true, foo, flush);
    BOOST_CHECK_EQUAL(output->str(), "Bool is: true, but not 543, 987\n");

    // test 5 args but only two formats
    output.reset( new std::ostringstream);
    prints(*output, "Foo is: %s, but not %s!\n", foo, 123, foo, "hi", '\n');
    BOOST_CHECK_EQUAL(output->str(), "Foo is: 543, 987, but not 123!\n543, 987hi\n");

    // test filling with blank and %
    output.reset( new std::ostringstream);
    prints(*output, "Preceding with blanks and %%: %10s%!%10s", 1977, 1978);
    BOOST_CHECK_EQUAL(output->str(), "Preceding with blanks and %:       1977%%%%%%1978");

    // test filling with 0's
    output.reset( new std::ostringstream);
    prints(*output, "Preceding with zeros: %010s", 1977);
    BOOST_CHECK_EQUAL(output->str(), "Preceding with zeros: 0000001977");

    // test different bases and upper/lower
    output.reset( new std::ostringstream);
    prints(*output, "Some different radixes: %s %xs %os %#Xs %#os", 200, 200, 200, 200, 200);
    BOOST_CHECK_EQUAL(output->str(), "Some different radixes: 200 c8 310 0XC8 0310");

    // test different floating point value formats
    output.reset( new std::ostringstream);
    prints(*output, "floats: %5.3fs %Es % _+7.3gs", 3.1416, 3.1416, 3.1416);
    BOOST_CHECK_EQUAL(output->str(), "floats: 3.142 3.141600E+000 +  3.14");

    // test for 0 precision 
    output.reset( new std::ostringstream);
    prints(*output, "floats 0 prec: %.0fs %.0es", 3.1416, 3.1416);
#if ! defined _MSC_VER // anything not Microsoft:
    BOOST_CHECK_EQUAL(output->str(), "floats 0 prec: 3 3e+000"); 
#else // VC++ has bug!
    BOOST_CHECK_EQUAL(output->str(), "floats 0 prec: 3 3.141600e+000"); 
#endif

    // test persistent format
    output.reset( new std::ostringstream);
    prints(*output, fmt_spec("%#X"));
    prints(*output, "ints: %s %ds %xs", 254, 254, 254);
    BOOST_CHECK_EQUAL(output->str(), "ints: 0XFE 254 0xfe");
    
    output.reset( new std::ostringstream);
    prints(*output, "ints: %8#_0XS, %!0ds, %xs", 254, 254, 254);
    BOOST_CHECK_MESSAGE(output->str() == "ints: 0X0000FE, 254, 0x0000fe", output->str());

    // test exception when too many markers
    output.reset( new std::ostringstream);
    try {prints(*output, "%s%s", 123);}
    catch (const iof::too_many_markers& exc) {BOOST_CHECK_EQUAL(exc.pos, size_t(3));}
    BOOST_CHECK_THROW(prints(*output, "%s%s", 123), iof::too_many_markers);
    
    // test exception when marker not closed
    output.reset(new std::ostringstream);
    try {prints(*output, "%.2__", 123);}
    catch (const iof::marker_not_closed_fmt& exc) {BOOST_CHECK_EQUAL(exc.start, size_t(1));}
    BOOST_CHECK_THROW(prints(*output, "%.2__", 123), iof::marker_not_closed_fmt);
}

BOOST_AUTO_TEST_CASE( testFmtSpecOut )
{
    std::ostringstream input("abc");
    BOOST_CHECK_THROW(input << iof::fmt_spec("="), std::runtime_error);
    BOOST_CHECK_THROW(input << iof::fmtr("") << iof::fmt_spec("="), std::runtime_error);
}

    
BOOST_AUTO_TEST_SUITE_END();
