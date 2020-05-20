#include <boost/test/auto_unit_test.hpp>
#include "iof/omanips.hpp"
#include "iof/stringizer.hpp"
#include "iof/tostr.hpp"
#include "iof/fmt_guard.hpp"
#include "iof/skip_past.hpp"
#include "stream_fmt_out.hpp"
using namespace iof;


BOOST_AUTO_TEST_SUITE( suiteStringizer );

BOOST_AUTO_TEST_CASE( testFormatter )
{
    // output with fmtr
    std::ostringstream msg;
    iof_private::fmtr_out(msg, "hi %xs, %ds, %as=1", false) & 17 & 17 & bool(1) & eol;
    BOOST_CHECK_MESSAGE(msg.str() == "hi 11, 17, true=1\n", msg.str());
    std::ostringstream msg1;
    iof_private::fmtr_out(msg1, "abc%sdef%s gh", false) & '\n' & 123 & std::endl;
    BOOST_CHECK_MESSAGE(msg1.str() == "abc\ndef123 gh\n", msg1.str());
    
    std::ostringstream msg2;
    msg2 << fmtr("hi ");
    msg2 << fmtr("%xs, %ds, %as=1") & 17 & 17 & bool(1) & std::endl;
    BOOST_CHECK_EQUAL(msg2.str(), msg.str());
    BOOST_CHECK_THROW(msg2 << fmtr("%s"),        too_many_markers); 
    BOOST_CHECK_THROW(msg2 << fmtr("%s%s") << 1, too_many_markers); 
    //BOOST_CHECK_THROW(msg2 << fmtr("") << fmt_spec(""), fmt_no_effect); 
    
    // test restore stream format after persistence
    std::ostringstream output2;
    stream_fmt fmt(output2);
    output2 << fmtr("%S") << fmt_spec("#f4.2-0") << 0x17;
    BOOST_CHECK_EQUAL(fmt, stream_fmt(output2));
}


BOOST_AUTO_TEST_CASE( testStringizer )
{
    // test basic
    std::string msg = stringizer("hi");
    BOOST_CHECK_EQUAL(msg, "hi");

    // test too many markers
    BOOST_CHECK_THROW(std::string(stringizer("hi%s")), too_many_markers);
        
    // test formatting of one obj
    std::string msg2 = stringizer("hi %s") & "joe";
    BOOST_CHECK_EQUAL(msg2, "hi joe");
    // test formatting of two obj
    std::string msg3 = stringizer("hi %s: %s") & "joe" & 17;
    BOOST_CHECK_EQUAL(msg3, "hi joe: 17");
    
    // test non-formatted
    std::string msg4 = stringizer("hi ") & "joe";
    BOOST_CHECK_EQUAL(msg4, "hi joe");
    
    // test copy, equality, etc
    stringizer ss("hi %s: %s");
    BOOST_CHECK(stringizer(ss) == ss);
    stringizer ss2(stringizer(ss) & "joe");
    BOOST_CHECK(ss != ss2);
    msg3 = ss & "joe" & 42;
    msg4 = ss2 & 42;
    BOOST_CHECK_MESSAGE(msg4 == "hi joe: 42", msg4);
    BOOST_CHECK_MESSAGE(msg4 == msg3, msg3);
}


BOOST_AUTO_TEST_CASE( testStreamFmt )
{
    stream_fmt fmt(std::cout);
    std::ostringstream out;
    stream_fmt fmt2(out);
    BOOST_CHECK_EQUAL(fmt, fmt2);
    
    fmt_spec fmt3("#xa 7.4");
    std::string result = tostr("%S %s %s", fmt3, true, 0x16, 32.123);
    BOOST_CHECK_EQUAL(result, "   true 0x   16   32.12");
    
    // test format guard
    {
        fmt_guard guard(std::cout);
        std::cout << fmt3;
        BOOST_CHECK(stream_fmt(std::cout) != fmt);
    }
    BOOST_CHECK_EQUAL(stream_fmt(std::cout), fmt);
    
    // test fmt::operator()
    fmt_spec hex("_#08X");
    std::string s17 = tostr("%s", hex(17));
    BOOST_CHECK_EQUAL(s17, "0X000011");
    // same, but uses centering with fill char
    fmt_spec center("10=");
    std::string res = tostr("%!_s, %8!=s", center(1234), 4321);
    BOOST_CHECK_MESSAGE(res == "___1234___, ====4321", "'" << res << "'");
    // same, but with persistence
    std::string res2 = tostr("%!_S, %!=s", center(1234), 4321);
    BOOST_CHECK_MESSAGE(res2 == "___1234___, ===4321===", "'" << res2 << "'");
    std::string res3 = tostr("%3=!_S, %s, %s", 1,2,3);
    BOOST_CHECK_MESSAGE(res3 == "_1_, _2_, _3_", "'" << res3 << "'");
        
    // test exception
    //BOOST_CHECK_THROW(tostr("%s", hex), fmt_no_effect);
}

    
BOOST_AUTO_TEST_SUITE_END();
