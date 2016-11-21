#ifndef __RSCODEC__H
#define __RSCODEC__H

#include <iostream>
#include <stdlib.h>
using namespace std;

#define b0 0

extern int m_m;
extern int nn;
extern int kk;
extern int tt;
extern int recd[15];
extern int data[15];
extern int bb[15];

int generate_gf();
int gen_poly();
int init_rs(int m);
int encode_rs();
int decode_rs();

#endif