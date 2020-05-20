/** Unit testing for iof library.  Uses the Boost unit testing framework.
    
    To build with g++, use:
    
    g++ -Wall -DEXTRA_MARKERS_NO_ASSERT -DEXTRA_MARKERS_THROW -I ../include \
        -I /c/Boost/include/boost-1_33_1  -g -o iof_test  \
        test_*.cpp -L/c/Boost/lib -l libboost_unit_test_framework-mgw

    or with VC++ use the test.vcproj project file (assumes boost in C:\Boost). 

    Copyright 2006 @ Oliver Schoenborn. This file is licensed under BSD.
    
    \author Oliver Schoenborn
    \version $Id: test_main.cpp 67 2006-05-21 04:33:08Z schoenborno $
*/

#define BOOST_AUTO_TEST_MAIN "IOF library regression testing"
#include <boost/test/auto_unit_test.hpp>


