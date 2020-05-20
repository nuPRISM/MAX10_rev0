/*
 * bel_fft_encapsulator.cpp
 *
 *  Created on: May 6, 2019
 *      Author: user
 */

#include "bel_fft_encapsulator.h"


namespace belfft {

belfft_encapsulator::belfft_encapsulator() {
	// TODO Auto-generated constructor stub

}

belfft_encapsulator::~belfft_encapsulator() {
	// TODO Auto-generated destructor stub
}


belfft_encapsulator::belfft_encapsulator(unsigned long the_base_address, uint32_t fftlen,  belfft_allowed_fft_set_type the_allowed_fft_lengths, std::string name, unsigned long span) : generic_driver_encapsulator(the_base_address,span, name,belfft_bytes_per_register_location) {
  this->set_has_been_initialized(false);
  this->set_allowed_fft_lengths(the_allowed_fft_lengths);
  this->set_fft_len(fftlen);
}

bool belfft_encapsulator::this_fft_length_is_legal(uint32_t the_len) {
	belfft_allowed_fft_set_type::const_iterator search_iterator = this->allowed_fft_lengths.find(the_len);
	if (search_iterator == this->allowed_fft_lengths.end()) {
	     return false;
	} else {
		return true;
	}

}



BELFFT_FUNCTION_CODE_RETURN_VALUES belfft_encapsulator::do_fft(kiss_fft_cpx *fin,kiss_fft_cpx *fout, uint32_t fft_length) {
	if (this_fft_length_is_legal(fft_length)) {
      if ((!this->is_has_been_initialized()) || (fft_length != this->get_fft_len())) {
    	this->set_fft_len(fft_length);
     	this->init();
     }
     return internal_do_fft (fin, fout);
	} else {
		return BELFFT_THIS_FFT_LENGTH_IS_NOT_SUPPORTED;
	}
}

BELFFT_FUNCTION_CODE_RETURN_VALUES belfft_encapsulator::init() {
    if (kf_factor(this->get_fft_len(), this->factors)) {
    	this->set_has_been_initialized(true);
    	return BELFFT_OK;
    } else {
    	return BELFFT_NOT_OK;
    }
}

BELFFT_FUNCTION_CODE_RETURN_VALUES belfft_encapsulator::internal_do_fft_stride (kiss_fft_cpx *fin, kiss_fft_cpx *fout, int in_stride)
{
    short int *facbuf;
    int i;

    if (!(this->is_has_been_initialized())) {
    	return BELFFT_ERROR_NOT_INITIALIZED;
    }
    /*
     *  Set bit 31 to bypass the cache on the NIOSII.
     */

    //volatile struct bel_fft * belFftPtr = (struct bel_fft *) (FFT_BASE + 0x80000000);
	volatile struct bel_fft * belFftPtr = (struct bel_fft *) this->get_base_address(); //assuming no data cache in processor

    /*
     * Set the size, source and destination address
     */

    belFftPtr->N.N = this->get_fft_len();
    belFftPtr->Finadr = fin;
    belFftPtr->Foutadr = fout;

    /*
     * Copy the precalculated factors.
     */

    facbuf = factors;
    i = 0;
    while (1) {
        belFftPtr->Factors[i].P = *facbuf++;
        belFftPtr->Factors[i].M = *facbuf;
        if (*facbuf++ == 1) {
            break;
        }
        i++;
    }

    /*
     * Flush the data cache for the source and destination region
     */

  //   alt_dcache_flush (fin, cfg->nfft * sizeof (kiss_fft_cpx));
  //  alt_dcache_flush (fout, cfg->nfft * sizeof (kiss_fft_cpx));

    /*
     * Since we poll the status register we do not enable the interrupt
     */

    /* cfg->belFftPtr->Control.Inten = 1; */

    /*
     * Start the FFT
     */

    belFftPtr->Control.Start = 1;

    /*
     * We poll the status register until the FFT is ready. Other implementations
     * like generation an interrupt are possible.
     */

    while (! belFftPtr->Status.Int) {
    }
    return BELFFT_OK;
}


BELFFT_FUNCTION_CODE_RETURN_VALUES belfft_encapsulator::internal_do_fft( kiss_fft_cpx *fin, kiss_fft_cpx *fout)
{
	return internal_do_fft_stride (fin, fout, 1);
}




} /* namespace belfft */
