
int32_t wrapper_randomx_get_id();
void wrapper_randomx_release_id(int32_t id);

void wrapper_randomx_init(int32_t id, uint8_t* key, int32_t length, bool fullMem);

int32_t wrapper_randomx_size_of_hash();

void wrapper_randomx_hash(int32_t id, uint8_t* bytes, int32_t length, uint8_t* out);

void wrapper_randomx_hash_first(int32_t id, uint8_t* bytes, int32_t length);
void wrapper_randomx_hash_next(int32_t id, uint8_t* bytes, int32_t length, uint8_t* outPrev);
void wrapper_randomx_hash_last(int32_t id, uint8_t* outPrev);

void wrapper_randomx_destroy(int32_t id);
