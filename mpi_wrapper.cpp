#include <iostream>
#include <stdlib.h>
#include <string>
#include <sstream>

// To compile: mpiCC -lmpi -o mpi_wrapper.exe mpi_wrapper.cpp
using namespace std;

#include "mpi.h"

int main (int argc, char * argv[]) {
 
    if (argc != 3) {	// we are expecting (i) base config file name and (ii) base task number
	cout << "Incorrect number of arguments - " << argc << endl;
	return 1;
    }
    
    int base_id = argc ? atoi( argv[2] ) : 0;
     
    // cout << "Here we are!" << endl;

    MPI_Init( &argc, &argv );
    
    // cout << "Init'ed OK" << endl;

    int id;
    MPI_Comm_rank(MPI_COMM_WORLD,&id);
    int size;
    MPI_Comm_size(MPI_COMM_WORLD,&size);
    cout << "I think the size is: " << size << endl;

    // cout << "Got rank OK" << endl;
    
    int final_id = id + base_id;
    //cout << final_id << endl;
    
    stringstream command2;
    command2 << "bash run_model.sh " << argv[1] << " " << final_id;

    cout << "About to run: " << command2.str() << endl;
   
    int result = system(command2.str().c_str());

    MPI_Finalize();
    
    return result;
}

