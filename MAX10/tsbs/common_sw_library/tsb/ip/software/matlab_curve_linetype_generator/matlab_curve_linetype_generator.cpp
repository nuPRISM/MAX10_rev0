/*
 * matlab_curve_linetype_generator.cpp
 *
 *  Created on: May 5, 2011
 *      Author: linnyair
 */

#include "matlab_curve_linetype_generator.h"

using namespace std;

matlab_curve_linetype_generator::matlab_curve_linetype_generator()
{

	//============================================================================
	//
	// Initialize Matlab Curve Plotting
	//
	//============================================================================
	matlab_line_types.push_back("-");
	matlab_line_types.push_back(":");
	matlab_line_types.push_back("-.");

	matlab_marker_types.push_back("o");
	matlab_marker_types.push_back("s");
	matlab_marker_types.push_back("^");
	matlab_marker_types.push_back("*");
	matlab_marker_types.push_back("x");
	matlab_marker_types.push_back("d");
	matlab_marker_types.push_back("v");
	matlab_marker_types.push_back("<");
	matlab_marker_types.push_back("p");
	matlab_marker_types.push_back(">");

	matlab_line_colors.push_back("b");
	matlab_line_colors.push_back("r");
	matlab_line_colors.push_back("g");
	matlab_line_colors.push_back("c");
	matlab_line_colors.push_back("m");
	matlab_line_colors.push_back("y");
	matlab_line_colors.push_back("k");

	current_linetype_index = 0;
	current_color_index = 0;
	current_shape_index = 0;
	linetype_starting_index = 0;
	color_starting_index = 0;
	shape_starting_index = 0;
	current_total_curve_number = 0;
}
/*
matlab_curve_linetype_generator::~matlab_curve_linetype_generator()
{
	// TODO Auto-generated destructor stub
}
*/
void matlab_curve_linetype_generator::reset_curve_count()
{
	current_linetype_index = 0;
	current_color_index = 0;
	current_shape_index = 0;
	linetype_starting_index = 0;
	color_starting_index = 0;
	shape_starting_index = 0;
	current_total_curve_number = 0;
}

void matlab_curve_linetype_generator::set_increase_every(unsigned int linetypemode, unsigned int colormod, unsigned int shapemod)
{
	color_increase_every = colormod;
	shape_increase_every = shapemod;
	linetype_increase_every = linetypemode;
}
string matlab_curve_linetype_generator::get_next_curve_type()
{
	string current_curve_str = "";
	current_curve_str += matlab_line_colors.at(current_color_index);
	current_curve_str += matlab_marker_types.at(current_shape_index);
	current_curve_str += matlab_line_types.at(current_linetype_index);

	if (mode == MATLAB_CURVE_LINEGEN_MANUAL)
	{
		current_total_curve_number++;
		if ((current_total_curve_number % color_increase_every) == 0)
			current_color_index++;
		if (current_color_index == matlab_line_colors.size())
		{
			color_starting_index = (color_starting_index + 1) % matlab_line_colors.size();
			current_color_index = color_starting_index;
		}

		if ((current_total_curve_number % shape_increase_every) == 0)
			current_shape_index++;
		if (current_shape_index == matlab_marker_types.size())
		{
			shape_starting_index = (shape_starting_index + 1) % matlab_marker_types.size();
			current_shape_index = shape_starting_index;
		}

		if ((current_total_curve_number % linetype_increase_every) == 0)
			current_linetype_index++;
		if (current_linetype_index == matlab_line_types.size())
		{
			linetype_starting_index = (linetype_starting_index + 1) % matlab_line_types.size();
			current_linetype_index = linetype_starting_index;
		}

	} else
	{
		current_color_index++;
		if (current_color_index == matlab_line_colors.size())
		{
			color_starting_index = (color_starting_index + 1) % matlab_line_colors.size();
			current_color_index = color_starting_index;

			current_shape_index++;
			if (current_shape_index == matlab_marker_types.size())
			{
				shape_starting_index = (shape_starting_index + 1) % matlab_marker_types.size();
				current_shape_index = shape_starting_index;

				current_linetype_index++;
				if (current_linetype_index == matlab_line_types.size())
				{
					linetype_starting_index = (linetype_starting_index + 1) % matlab_marker_types.size();
					current_linetype_index = linetype_starting_index;
				}
			}
		}
	}
	return current_curve_str;
}

