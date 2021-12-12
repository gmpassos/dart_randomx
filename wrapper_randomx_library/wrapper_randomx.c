
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <pthread.h>

#include "RandomX/src/randomx.h"
#include "wrapper_randomx.h"

randomx_cache* _randomXCaches[1024];
randomx_dataset* _randomXDatasets[1024];
randomx_vm* _vms[1024];

void _printBytes(char* message, uint8_t* bytes, int32_t length) {
    printf("%s: ", message);
    for (unsigned i = 0; i < length; ++i)
        printf("%02x", bytes[i] & 0xff);
    printf("\n");
}

struct _thread_args_struct
{
   int32_t id;
   unsigned long startItem;
   unsigned long itemCount;
} ;

void *_thread_init_dataset(void *arguments) {
   struct _thread_args_struct *args = arguments;
   int32_t id = args->id;

   //printf("[RandomX] randomx_init_dataset[%d]> startItem: %lu ; itemCount: %lu\n", id, args->startItem, args->itemCount);

   randomx_init_dataset(_randomXDatasets[id], _randomXCaches[id], args->startItem, args->itemCount);

   pthread_exit(NULL);
   return NULL;
}

void wrapper_randomx_init(int32_t id, uint8_t* key, int32_t length, bool fullMem) {
    randomx_flags flags;
    //printf("[RandomX] init[%d] key: %s\n", id, key);

    flags = randomx_get_flags();
    flags |= RANDOMX_FLAG_JIT;
    flags |= RANDOMX_FLAG_SECURE;

    if (fullMem) {
        flags |= RANDOMX_FLAG_FULL_MEM;
    }

    _randomXCaches[id] = randomx_alloc_cache(flags);
    randomx_init_cache(_randomXCaches[id], key, length);

    if (fullMem) {
        pthread_t t1, t2, t3;

        unsigned long datasetItemCount = randomx_dataset_item_count();
        unsigned long datasetItemsPerThread = datasetItemCount/3;
        unsigned long datasetItemOffset = 0;

        _randomXDatasets[id] = randomx_alloc_dataset(flags);

        //// Single thread:
        // randomx_init_dataset(_randomXDatasets[id], _randomXCaches[id], 0, datasetItemCount);

        struct _thread_args_struct *th_args1 = malloc(sizeof(struct _thread_args_struct));
        struct _thread_args_struct *th_args2 = malloc(sizeof(struct _thread_args_struct));
        struct _thread_args_struct *th_args3 = malloc(sizeof(struct _thread_args_struct));

        th_args1->id = id;
        th_args1->startItem = datasetItemOffset;
        th_args1->itemCount = datasetItemsPerThread;
        datasetItemOffset += datasetItemsPerThread;

        th_args2->id = id;
        th_args2->startItem = datasetItemOffset;
        th_args2->itemCount = datasetItemsPerThread;
        datasetItemOffset += datasetItemsPerThread;

        th_args3->id = id;
        th_args3->startItem = datasetItemOffset;
        th_args3->itemCount = datasetItemCount - datasetItemOffset;

        pthread_create(&t1, NULL, _thread_init_dataset, (void *) th_args1);
        pthread_create(&t2, NULL, _thread_init_dataset, (void *) th_args2);
        pthread_create(&t3, NULL, _thread_init_dataset, (void *) th_args3);

        pthread_join(t1, NULL);
        pthread_join(t2, NULL);
        pthread_join(t3, NULL);

        free(th_args1);
        free(th_args2);
        free(th_args3);

        randomx_release_cache(_randomXCaches[id]);
        _randomXCaches[id] = NULL ;

        _vms[id] = randomx_create_vm(flags, NULL, _randomXDatasets[id]);
    }
    else {
        _randomXDatasets[id] = NULL ;
        _vms[id] = randomx_create_vm(flags, _randomXCaches[id], NULL);
    }

}

int32_t wrapper_randomx_size_of_hash() {
    return RANDOMX_HASH_SIZE ;
}

void wrapper_randomx_hash(int32_t id, uint8_t* bytes, int32_t length, uint8_t* out) {
    //printf("[RandomX] hash[%d]> length: %d\n", id, length);

    //_printBytes("bytes", bytes, length);
    randomx_calculate_hash(_vms[id], bytes, length, out);
    //_printBytes("hash", out, RANDOMX_HASH_SIZE);
}

void wrapper_randomx_hash_first(int32_t id, uint8_t* bytes, int32_t length) {
    //printf("[RandomX] hash_first[%d]> length: %d\n", id, length);

    //_printBytes("bytes", bytes, length);
    randomx_calculate_hash_first(_vms[id], bytes, length);
}

void wrapper_randomx_hash_next(int32_t id, uint8_t* bytes, int32_t length, uint8_t* outPrev) {
    //printf("[RandomX] hash_next[%d]> length: %d\n", id, length);

    //_printBytes("bytes", bytes, length);
    randomx_calculate_hash_next(_vms[id], bytes, length, outPrev);
    //_printBytes("hashPrev", outPrev, RANDOMX_HASH_SIZE);
}

void wrapper_randomx_hash_last(int32_t id, uint8_t* outPrev) {
    //printf("[RandomX] hash_last[%d]\n", id);

    randomx_calculate_hash_last(_vms[id], outPrev);
    //_printBytes("hashPrev", outPrev, RANDOMX_HASH_SIZE);
}

void wrapper_randomx_destroy(int32_t id) {
    //printf("[RandomX] destroy[%id]\n", id);

    randomx_destroy_vm( _vms[id] );
    _vms[id] = NULL;

    if (_randomXCaches[id] != NULL) {
        randomx_release_cache( _randomXCaches[id] );
    }

    if (_randomXDatasets[id] != NULL) {
        randomx_release_dataset( _randomXDatasets[id] );
    }
}
