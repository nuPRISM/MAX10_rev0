/*
 * matlab_curve_linetype_generator.h
 *
 *  Created on: May 5, 2011
 *      Author: linnyair
 */

#ifndef MATLAB_CURVE_LINETYPE_GENERATOR_H_
#define MATLAB_CURVE_LINETYPE_GENERATOR_H_
#include <alt_types.h>
#include <altera_avalon_pio_regs.h>
#include <sys/alt_irq.h>
#include <system.h>
#include <string>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <iostream>
#include <fstream>
#include <map>
#include <float.h>
#include <vector>
#include <unistd.h>
#include <time.h>
typedef enum {
	MATLAB_CURVE_LINEGEN_AUTO = 0, MATLAB_CURVE_LINEGEN_MANUAL = 1
} matlab_curvegen_mode_type;
class matlab_curve_linetype_generator {
	protected:
		unsigned int current_linetype_index;
		unsigned int current_color_index;
		unsigned int current_shape_index;
		unsigned int linetype_starting_index;
		unsigned int color_starting_index;
		unsigned int shape_starting_index;
		unsigned int current_total_curve_number;
		unsigned int color_increase_every;
		unsigned int shape_increase_every;
		unsigned int linetype_increase_every;
		matlab_curvegen_mode_type mode;
		std::vector<std::string> matlab_line_types;
		std::vector<std::string> matlab_marker_types;
		std::vector<std::string> matlab_line_colors;

	public:
		std::string get_next_curve_type();
		void set_increase_every(unsigned int linetypemode, unsigned int colormod, unsigned int shapemod);
		void set_mode(matlab_curvegen_mode_type the_mode)
		{
			mode = the_mode;
		}
		void reset_curve_count();
		matlab_curve_linetype_generator();
		//virtual ~matlab_curve_linetype_generator();
};

#endif /* MATLAB_CURVE_LINETYPE_GENERATOR_H_ */
