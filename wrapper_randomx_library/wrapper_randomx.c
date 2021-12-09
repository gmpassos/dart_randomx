
#include <stdio.h>
#include "../../src/randomx.h"
#include "wrapper_randomx.h"

randomx_cache* _randomCaches[1024];
randomx_vm* _vms[1024];

void wrapper_randomx_init(int32_t id, uint8_t* key, int32_t length) {
    randomx_flags flags;
    //printf("[RandomX] init[%d] key: %s\n", id, key);

    flags = randomx_get_flags();

    _randomCaches[id] = randomx_alloc_cache(flags);
    randomx_init_cache(_randomCaches[id], key, length);

    _vms[id] = randomx_create_vm(flags, _randomCaches[id], NULL);
}

int32_t wrapper_randomx_size_of_hash() {
    return RANDOMX_HASH_SIZE ;
}

void wrapper_randomx_hash(int32_t id, uint8_t* bytes, int32_t length, uint8_t* out) {
    //printf("[RandomX] hash[%d]> length: %d ; bytes: <%s> <%s>\n", id, length, bytes, out);

    /*
    printf("bytes: ");
    for (unsigned i = 0; i < length; ++i)
        printf("%02x", bytes[i] & 0xff);
    printf("\n");
    */

    randomx_calculate_hash(_vms[id], bytes, length, out);

    /*
    printf("hash: ");
    for (unsigned i = 0; i < RANDOMX_HASH_SIZE; ++i)
        printf("%02x", out[i] & 0xff);
    printf("\n");
    */
}

void wrapper_randomx_destroy(int32_t id) {
    //printf("[RandomX] destroy[%id]\n", id);

    randomx_destroy_vm( _vms[id] );
    randomx_release_cache( _randomCaches[id] );
}
