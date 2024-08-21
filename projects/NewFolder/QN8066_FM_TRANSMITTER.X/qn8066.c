/*
 * File:   qn8066.c
 * Author: rcaratti
 *
 * Created on August 20, 2024, 10:26 PM
 */


#include <xc.h>
#include "QN8066.h"

void set_register(unsigned char registerNumber, unsigned char value) {
    
}

unsigned char get_register(unsigned char registerNumber) {
    
    return 0;
}


void qn8066_begin() {
  reg_system1.raw = 0B11100011;
  reg_system2.raw = 0;
  reg_cca.raw = get_register(REG_CCA);
  reg_cca.arg.xtal_inj = 1; 
  reg_gplt.raw = get_register(REG_GPLT);
  reg_fdev.raw = get_register(REG_FDEV);
  reg_rds.raw =  get_register(REG_RDS);
  reg_reg_vga.raw = get_register(REG_REG_VGA);
  reg_int_ctrl.raw = get_register(REG_INT_CTRL);
  reg_pac.raw = get_register(REG_PAC);
  reg_vol_ctl.raw = get_register(REG_VOL_CTL);    
} 
