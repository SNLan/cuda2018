#include "Tools.h"

#include <iostream>
#include <iomanip>

using namespace std;

//define VERBOSE // Prints input matrix and results. Only uncomment for small matrix sizes!
#define RUN_CPU // Runs CPU code for reference (slow!!!)
#define N 100 // Must be a multiple of THREADS_PER_BLOCK
#define THREADS_PER_BLOCK 16 // per axis -> block has this value squared threads.

#define TILE_WIDTH 16

void multiplyMatrix(float* result, const float* a, const float* b, const int n)
{
	for (unsigned int i = 0; i < n; i++)
	{
		for (unsigned int j = 0; j < n; j++)
		{
			result[i * n + j] = 0.0f;
			for (unsigned int k = 0; k < n; k++)
			{
				result[i * n + j] += a[i * n + k] * b[k * n + j];
			}
		}
	}
}

void dumpMatrix(const float* m, const int n)
{
	for (unsigned int i = 0; i < n; i++)
	{
		for (unsigned int j = 0; j < n; j++)
		{
			cout << setw(3) << setprecision(3) << m[i * n + j] << " ";
		}
		cout << endl;
	}
}

float randF(const float min = 0.0f, const float max = 1.0f)
{
	int randI = rand();
	float randF = (float) randI / (float) RAND_MAX;
	float result = min + randF * (max - min);

	return result;
}

__global__ void multiplyMatrixGpu1(float* result, const float* a,
		const float* b, const int n)
{
	// TODO: Implement a trivial GPU square matrix multiplication.
	// Use one thread per output element.

	int row = blockIdx.x * THREADS_PER_BLOCK + threadIdx.x;
	int col = blockIdx.y * THREADS_PER_BLOCK + threadIdx.y;

	float sum = 0;
	if(row < n && col < n)
	{
	    for(int k = 0; k < n; k++){
				sum += a[row * n + k] * b[k * n + col];
			}
	    result[row * n + col] = sum;
	}
}
	//int threadId = (blockIdx.y * blockDim.y + threadIdx.y) * gridDim.x * blockDim.x + blockIdx.x * blockDim.x + threadIdx.x;

	//if (threadId < n * n)
	//{
	//	int row = threadId/n;
	//	int col = threadId/n;
	//	result[threadId] = 0;
	//	for(int k = 0; k < n; k++){
	//		result[threadId] += a[row * n + k] * b[k * n + col];
	//	}
	//}
    //template<int BLOCK_SIZE>

__global__ void multiplyMatrixGpu2(float* result, const float* a,
		const float* b, const int n)
{
	// TODO: Implement a more sophisticated GPU square matrix multiplication.
	// Compute square submatrices per block. Load the common input
	// data of all threads of a block into shared memory cooperatively.


	__shared__ float sub_a[16][16];
	__shared__ float sub_b[16][16];

	int bx = blockIdx.x;
	int by = blockIdx.y;
	int tx = threadIdx.x;
	int ty = threadIdx.y;

	float sum = 0;
	__syncthreads();

	for(int i = 0; i < 16; i++){
			sum += sub_a[ty][i] * sub_b[i][tx];
			__syncthreads();
	}
	result[n] = sum;
}


// delete

//__global__ void multiplyMatrixGpu2(float* result, const float* a,
//		const float* b, const int n){
//
//	int bx = blockIdx.x;
//	int by = blockIdx.y;
//
//	int tx = threadIdx.x;
//	int ty = threadIdx.y;
//
//	float mulResult =0.0;
//
//	for(int i=0; i<gridDim.x; ++i){
//		__shared__ float d_m[TILE_WIDTH][TILE_WIDTH];
//		__shared__ float d_n[TILE_WIDTH][TILE_WIDTH];
//		d_m[ty][tx] = *(a+(by*blockDim.y+ty)*n+i*blockDim.x+tx);
//		d_n[ty][tx] = *(b+(i*blockDim.y+ty)*n+bx*blockDim.x+tx);
//		__syncthreads();
//		for(int j=0; j<blockDim.x;++j){
//			float temp = d_m[ty][j]* d_n[j][tx];
//			mulResult = mulResult + temp;
//		}
//		__syncthreads();
//	}
//
//	result[(by*blockDim.y+ty)*n+bx*blockDim.x+tx] = mulResult;
//}




int main(int argc, char **argv)
{
	__int64_t startTime;
	__int64_t endTime;

	// Allocate all memory
	float* hM1 = new float[N * N];
	float* hM2 = new float[N * N];
	float* hMR = new float[N * N];
	float* gM1;
	cudaMalloc(&gM1, sizeof(float) * N * N);
	float* gM2;
	cudaMalloc(&gM2, sizeof(float) * N * N);
	float* gMR;
	cudaMalloc(&gMR, sizeof(float) * N * N);

	// Initialize matrices and upload to CUDA
	for (unsigned int n = 0; n < N * N; n++)
	{
		hM1[n] = randF(-1.0, 1.0);
		hM2[n] = randF(-1.0, 1.0);
	}
	cudaMemcpy(gM1, hM1, sizeof(int) * N * N, cudaMemcpyHostToDevice);
	cudaMemcpy(gM2, hM2, sizeof(int) * N * N, cudaMemcpyHostToDevice);
#ifdef VERBOSE
	cout << "Input Matrices:" << endl;
	dumpMatrix(hM1, N);
	cout << endl;
	dumpMatrix(hM2, N);
	cout << endl << endl;
#endif

#ifdef RUN_CPU
	// Calculations on CPU
	startTime = continuousTimeNs();
	multiplyMatrix(hMR, hM1, hM2, N);
	endTime = continuousTimeNs();
#ifdef VERBOSE
	cout << "CPU:" << endl;
	dumpMatrix(hMR, N);
	cout << endl;
#endif
	cout << "CPU time: " << (endTime - startTime) << "ns" << endl;
#endif

	// Calculations on GPU
	int blocksPerGridX =
			N % THREADS_PER_BLOCK == 0 ?
					N / THREADS_PER_BLOCK : N / THREADS_PER_BLOCK + 1;
	int blocksPerGridY =
			N % THREADS_PER_BLOCK == 0 ?
					N / THREADS_PER_BLOCK : N / THREADS_PER_BLOCK + 1;
	startTime = continuousTimeNs();
	multiplyMatrixGpu1<<<dim3(blocksPerGridX, blocksPerGridY, 1),
			dim3(THREADS_PER_BLOCK, THREADS_PER_BLOCK, 1)>>>(gMR, gM1, gM2, N);
	cudaDeviceSynchronize();
	endTime = continuousTimeNs();
	cudaMemcpy(hMR, gMR, sizeof(float) * N * N, cudaMemcpyDeviceToHost);
#ifdef VERBOSE
	cout << "GPU simple:" << endl;
	dumpMatrix(hMR, N);
	cout << endl;
#endif
	cout << "GPU simple time: " << (endTime - startTime) << "ns" << endl;
	startTime = continuousTimeNs();
	multiplyMatrixGpu2<<<dim3(blocksPerGridX, blocksPerGridY, 1),
			dim3(THREADS_PER_BLOCK, THREADS_PER_BLOCK, 1)>>>(gMR, gM1, gM2, N);
	cudaDeviceSynchronize();
	endTime = continuousTimeNs();
	cudaMemcpy(hMR, gMR, sizeof(float) * N * N, cudaMemcpyDeviceToHost);
#ifdef VERBOSE
	cout << "GPU advanced:" << endl;
	dumpMatrix(hMR, N);
	cout << endl;
#endif
	cout << "GPU advanced time: " << (endTime - startTime) << "ns" << endl;

	// Free all memory
	cudaFree(gM1);
	cudaFree(gM2);
	cudaFree(gMR);
	delete[] hM1;
	delete[] hM2;
	delete[] hMR;
}
