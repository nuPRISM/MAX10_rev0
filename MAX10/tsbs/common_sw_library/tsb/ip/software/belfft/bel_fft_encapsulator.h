/*
 * bel_fft_encapsulator.h
 *
 *  Created on: May 6, 2019
 *      Author: user
 */

#ifndef BEL_FFT_ENCAPSULATOR_H_
#define BEL_FFT_ENCAPSULATOR_H_

#include <stdint.h>
#include "bel_fft.hpp"
#include "kiss_fft.hpp"
#include "generic_driver_encapsulator.h"
#include <set>

namespace belfft {
const unsigned long belfft_bytes_per_register_location = 4;
const unsigned long belfft_bytes_per_register_span = belfft_bytes_per_register_location*MAXFACTORS + 5*belfft_bytes_per_register_location;

typedef enum {
	BELFFT_OK = 0,
	BELFFT_NOT_OK = 1,
	BELFFT_ERROR_NULL_POINTER = 2,
	BELFFT_ERROR_NOT_INITIALIZED = 3,
	BELFFT_THIS_FFT_LENGTH_IS_NOT_SUPPORTED = 4
} BELFFT_FUNCTION_CODE_RETURN_VALUES;
typedef std::set<uint32_t> belfft_allowed_fft_set_type;
class belfft_encapsulator: public generic_driver_encapsulator {
protected:

    int nstage;
    short int factors[2*MAXFACTORS];
	uint32_t fft_len;
	belfft_allowed_fft_set_type allowed_fft_lengths;
	bool has_been_initialized;
	virtual BELFFT_FUNCTION_CODE_RETURN_VALUES internal_do_fft( kiss_fft_cpx *fin, kiss_fft_cpx *fout);
	virtual BELFFT_FUNCTION_CODE_RETURN_VALUES internal_do_fft_stride (kiss_fft_cpx *fin, kiss_fft_cpx *fout, int in_stride);


public:
	belfft_encapsulator();
	belfft_encapsulator(unsigned long the_base_address,  uint32_t fftlen, belfft_allowed_fft_set_type the_allowed_fft_lengths, std::string name = "undefined", unsigned long span = belfft_bytes_per_register_span);

	virtual ~belfft_encapsulator();

	/*
	 * kiss_fft(cfg,in_out_buf)
	 *
	 * Perform an FFT on a complex input buffer.
	 * for a forward FFT,
	 * fin should be  f[0] , f[1] , ... ,f[nfft-1]
	 * fout will be   F[0] , F[1] , ... ,F[nfft-1]
	 * Note that each element is complex and can be accessed like
	    f[k].r and f[k].i
	 * */
	virtual BELFFT_FUNCTION_CODE_RETURN_VALUES init();

	virtual BELFFT_FUNCTION_CODE_RETURN_VALUES do_fft(kiss_fft_cpx *fin,kiss_fft_cpx *fout, uint32_t fft_length);

	virtual bool this_fft_length_is_legal(uint32_t the_len);

	virtual uint32_t get_fft_len() {
		return fft_len;
	}

	virtual void set_fft_len(uint32_t fft_len) {
		this->fft_len = fft_len;
	}

	virtual bool is_has_been_initialized() {
		return has_been_initialized;
	}

	virtual void set_has_been_initialized(bool has_been_initialized) {
		this->has_been_initialized = has_been_initialized;
	}

	belfft_allowed_fft_set_type get_allowed_fft_lengths() const {
		return allowed_fft_lengths;
	}

	void set_allowed_fft_lengths(const belfft_allowed_fft_set_type& allowed_fft_lengths) {
		this->allowed_fft_lengths = allowed_fft_lengths;
	}
};

} /* namespace belfft */

#endif /* BEL_FFT_ENCAPSULATOR_H_ */
