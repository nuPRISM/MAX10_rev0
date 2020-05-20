/** Unit testing for process_* files. Uses the Boost unit testing framework.
    
    Copyright 2006 @ Oliver Schoenborn. This file is licensed under BSD License.
    
    \author Oliver Schoenborn
    \version $Id: test_process_fmt_out.cpp 68 2006-05-21 06:13:23Z schoenborno $
*/

#include <boost/test/auto_unit_test.hpp>
#include <iostream>

#include "iof/process_fmt_out.hpp"
using namespace iof;
#include "test_foo.hpp"


//------------------ TESTING -----------------------

//====================================================
// Test processToNextFmtMarker() for output for cases where it is expected to return NULL
std::string testProcMarkerReturnsNULL_Out(const char* msg)
{
    std::ostringstream grab;
    grab.exceptions(std::ios::failbit | std::ios::badbit);
    BOOST_CHECK_EQUAL( iof_private::processToNextFmtMarker(grab, msg), (const char*)NULL );
    return grab.str();
}


// Test processToNextFmtMarker() for output for cases where it is expected 
// to return non-NULL, compare return value to msg+expect
std::string testProcMarkerReturnsNonNull_Out(const char* msg, int expect)
{
    std::ostringstream grab;
    grab.exceptions(std::ios::failbit | std::ios::badbit);
    const char* found = iof_private::processToNextFmtMarker(grab, msg);
    BOOST_CHECK_MESSAGE( found == (msg+expect),
        "marker test got " << size_t(found-msg) << ", expected " << expect );
    return grab.str();
}


BOOST_AUTO_TEST_SUITE( suiteProcessFmtOut );

// test basic case for output stream
BOOST_AUTO_TEST_CASE( testFindMarkerOut )
{
    BOOST_CHECKPOINT( "testFindMarkerOut" );
    // cases that should return NULL
    BOOST_CHECK_EQUAL( testProcMarkerReturnsNULL_Out("")    , "");
    BOOST_CHECK_EQUAL( testProcMarkerReturnsNULL_Out("\n")  , "\n");
    BOOST_CHECK_EQUAL( testProcMarkerReturnsNULL_Out("%%")  , "%");
    BOOST_CHECK_EQUAL( testProcMarkerReturnsNULL_Out("abc") , "abc");
    BOOST_CHECK_EQUAL( testProcMarkerReturnsNULL_Out("abc%%def%%"), "abc%def%");

    // cases that should point to a format marker (%)
    BOOST_CHECK_EQUAL( testProcMarkerReturnsNonNull_Out("%s", 1), "");
    BOOST_CHECK_EQUAL( testProcMarkerReturnsNonNull_Out("abc%%def%sabc", 9), "abc%def");
    BOOST_CHECK_EQUAL( testProcMarkerReturnsNonNull_Out("abc%", 4), "abc");
}


//====================================================

// Test process1FmtSpec() for cases where it returns NULL (fmt is last in msg)
template <typename TT>
std::string testProc1FmtSpec_Last_Out(char* msg, const TT& obj, bool expectCenter=false)
{
    std::ostringstream grab;
    bool restoreFmt; // not used
    iof_private::fmt_extensions fmtExtensions;
    const bool result 
        = iof_private::process1FmtSpec(grab, msg, fmtExtensions, restoreFmt, false) == NULL;
    BOOST_CHECK(result);//, "error: " << (msg ? msg : "NULL"));
    BOOST_CHECK_EQUAL(fmtExtensions.needCentering(), expectCenter);
    grab << obj;
    
    return grab.str();
}


// Test process1FmtSpec() for cases where it returns non-NULL (there 
// is stuff AFTER first fmt)
template <typename TT>
std::string testProc1FmtSpec_After_Out(char* msg, const TT& obj, 
    int expectFound, bool expectCenter=false)
{
    std::ostringstream grab;
    bool restoreFmt; // not used
    iof_private::fmt_extensions fmtExtensions;
    const char* found 
        = iof_private::process1FmtSpec(grab, msg, fmtExtensions, restoreFmt);
    BOOST_CHECK_MESSAGE( found == (msg+expectFound),
        "format test got " << size_t(found-msg) << ", expected " << expectFound );
    BOOST_CHECK_EQUAL(fmtExtensions.needCentering(), expectCenter);
    grab << obj;
    return grab.str();
}


void testMarkerNotClosedOut(const char* fmt)
{
    std::ostringstream grab;
    bool restoreFmt;
    iof_private::fmt_extensions fmtExtensions;
    try {
        iof_private::process1FmtSpec(grab, fmt, fmtExtensions, restoreFmt);
    }
    catch (const iof_private::failure& fail)
    {
        BOOST_CHECK_EQUAL(fail.problem, fmt);
        BOOST_CHECK_EQUAL(fail.errType, iof_private::failure::MARKER_NOT_CLOSED);
        throw;
    }
}


BOOST_AUTO_TEST_CASE( testProc1FmtSpecOut )
{
    std::string output = testProc1FmtSpec_Last_Out("s", 123);
    BOOST_CHECK_EQUAL(output, "123");
    output = testProc1FmtSpec_Last_Out(NULL, 123);
    BOOST_CHECK_EQUAL(output, "123");

    output = testProc1FmtSpec_Last_Out("-10.5", 123.5);
    BOOST_CHECK_EQUAL(output, "123.5     ");

    output = testProc1FmtSpec_Last_Out("\\8", 123.5);
    BOOST_CHECK_EQUAL(output, "\\\\\\123.5");

    output = testProc1FmtSpec_Last_Out("<!!8", 123.5);
    BOOST_CHECK_EQUAL(output, "123.5!!!");

    output = testProc1FmtSpec_Last_Out("<5!0", 1);
    BOOST_CHECK_EQUAL(output, "1");

    output = testProc1FmtSpec_Last_Out("8!!", 123.5);
    BOOST_CHECK_EQUAL(output, "!!!123.5");

    output = testProc1FmtSpec_Last_Out("-7.s", 123);
    BOOST_CHECK_EQUAL(output, "123....");
    
    output = testProc1FmtSpec_Last_Out("-7.", 123);
    BOOST_CHECK_EQUAL(output, "123....");
    
    output = testProc1FmtSpec_Last_Out("7.-", 123);
    BOOST_CHECK_EQUAL(output, "123....");
    
    output = testProc1FmtSpec_Last_Out("0-7", 123);
    BOOST_CHECK_EQUAL(output, "1230000");
    
    output = testProc1FmtSpec_Last_Out("0-7", 123);
    BOOST_CHECK_EQUAL(output, "1230000");
    
    output = testProc1FmtSpec_After_Out("!s10s, but not %s", Foo(), 5);
    BOOST_CHECK_EQUAL(output, "sssssss543, 987");
    
    // test exception when marker not closed
    BOOST_CHECK_THROW( testMarkerNotClosedOut(""), iof_private::failure); // top
    BOOST_CHECK_THROW( testMarkerNotClosedOut("!"), iof_private::failure); // bad escape
    BOOST_CHECK_THROW( testMarkerNotClosedOut(".2f"), iof_private::failure); // bottom
    
}


// ======== Alignment (centering, ...) =====================


void testCenterStr(int width, const char* msg, const std::string& expect, char fill = 0)
{
    std::ostringstream out;
    out.width(width);
    if (fill) out.fill(fill);
    iof_private::outputCentered( msg, out);
    BOOST_CHECK_EQUAL(out.str(), expect);
}


template <typename TT> 
void testCenterObj(int width, const TT& obj, const std::string& expect)
{
    std::ostringstream out;
    out.width(width);
    iof_private::fmt_extensions fmtExtensions;
    fmtExtensions.needCentering(true);
    iof_private::outputAdvanced(obj, out, fmtExtensions);
    BOOST_CHECK_EQUAL(out.str(), expect);
}


struct Bar {};
std::ostream& operator<<(std::ostream& out, const Bar&)
{
    out.width(3);
    return out << 1 << 'a' << true;
}

BOOST_AUTO_TEST_CASE( testCentering )
{
    testCenterStr(4, "", std::string(4, ' '));
    testCenterStr(4, "1",     " 1  ");
    testCenterStr(4, "12",    " 12 ");
    testCenterStr(4, "123",   "123 ");
    testCenterStr(4, "1234",  "1234");
    testCenterStr(4, "12345", "12345");
    testCenterStr(6, "12",    "--12--", '-');
    
    testCenterObj(4, 1,     " 1  ");
    testCenterObj(4, 12,    " 12 ");
    testCenterObj(4, 123,   "123 ");
    testCenterObj(4, 1234,  "1234");
    testCenterObj(4, 12345, "12345");
    
    testCenterObj(8, Bar(), "   1a1  ");
}

#include <ios>

template <typename TT> 
void testAlignObj(int width, std::ios_base::fmtflags alignFlag, 
    const TT& obj, const std::string& expect)
{
    std::ostringstream out;
    out.width(width);
    out.setf(alignFlag, std::ios_base::adjustfield);
    iof_private::fmt_extensions fmtExtensions;
    iof_private::outputAdvanced(obj, out, fmtExtensions);
    BOOST_CHECK_EQUAL(out.str(), expect);
}


#include <iomanip>

BOOST_AUTO_TEST_CASE( testAlignment )
{
    testAlignObj(4, std::ios_base::right, 1, "   1");
    testAlignObj(4, std::ios_base::left,  1, "1   ");
    testAlignObj(7, std::ios_base::right, Bar(), "    1a1");
    // if forget to call cancelAlignment, this will fail 
    // since numbers are *right*-justified by default
    testAlignObj(7, std::ios_base::left,  Bar(), "  1a1  ");
}

BOOST_AUTO_TEST_CASE( testFlush )
{
    std::ostringstream out;
    const char* ret = iof_private::processToNextMarker(out, "abc\fdef\n\f");
    BOOST_CHECK_EQUAL(ret, (const char*)NULL);
    BOOST_CHECK_EQUAL(out.str(), "abcdef\n");
}

BOOST_AUTO_TEST_CASE( testBackslashFNoEffect )
{
    std::istringstream in("abc\fdef\n\f");
    const char* ret = iof_private::processToNextMarker(in, "abc\fdef\n\f");
    BOOST_CHECK_EQUAL(ret, (const char*)NULL);
    BOOST_CHECK(in);
}

    
BOOST_AUTO_TEST_SUITE_END();
