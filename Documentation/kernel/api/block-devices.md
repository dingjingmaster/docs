# 块设备


## bio_advance

函数签名：
```c
void bio_advance(struct bio *bio, unsigned int nbytes);
```

## struct folio_iter

定义：
```c
struct folio_iter 
{
  struct folio *folio;
  size_t offset;
  size_t length;
};
```

## bio_for_each_folio_all

函数签名：
```c
bio_for_each_folio_all (fi, bio);
```

## bio_next_split

函数签名：
```c
struct bio *bio_next_split(struct bio *bio, int sectors, gfp_t gfp, struct bio_set *bs);
```

## blk_queue_flag_set

函数签名：
```c
void blk_queue_flag_set(unsigned int flag, struct request_queue *q);
```

## blk_queue_flag_clear

函数签名：
```c
void blk_queue_flag_clear(unsigned int flag, struct request_queue *q);
```

## blk_queue_flag_test_and_set

函数签名：
```c
bool blk_queue_flag_test_and_set(unsigned int flag, struct request_queue *q);
```

## blk_op_str

函数签名：
```c
const char *blk_op_str(enum req_op op);
```

## blk_sync_queue

函数签名：
```c
void blk_sync_queue(struct request_queue *q);
```

## blk_set_pm_only

函数签名：
```c
void blk_set_pm_only(struct request_queue *q);
```

## blk_put_queue

函数签名：
```c
void blk_put_queue(struct request_queue *q);
```

## blk_get_queue

函数签名：
```c
bool blk_get_queue(struct request_queue *q);
```

## submit_bio_noacct

函数签名：
```c
void submit_bio_noacct(struct bio *bio);
```

## submit_bio

函数签名：
```c
void submit_bio(struct bio *bio);
```

## bio_poll

函数签名：
```c
int bio_poll(struct bio *bio, struct io_comp_batch *iob, unsigned int flags);
```

## bio_start_io_acct_time

函数签名：
```c
void bio_start_io_acct_time(struct bio *bio, unsigned long start_time);
```

## bio_start_io_acct

函数签名：
```c
unsigned long bio_start_io_acct(struct bio *bio);
```

## blk_lld_busy

函数签名：
```c
int blk_lld_busy(struct request_queue *q);
```

## blk_start_plug

函数签名：
```c
void blk_start_plug(struct blk_plug *plug);
```

## blk_finish_plug

函数签名：
```c
void blk_finish_plug(struct blk_plug *plug);
```

## blk_queue_enter

函数签名：
```c
int blk_queue_enter(struct request_queue *q, blk_mq_req_flags_t flags);
```

## blk_rq_map_user_iov

函数签名：
```c
int blk_rq_map_user_iov(struct request_queue *q, struct request *rq, struct rq_map_data *map_data, const struct iov_iter *iter, gfp_t gfp_mask);
```

## blk_rq_unmap_user

函数签名：
```c
int blk_rq_unmap_user(struct bio *bio);
```

## blk_rq_map_kern

函数签名：
```c
int blk_rq_map_kern(struct request_queue *q, struct request *rq, void *kbuf, unsigned int len, gfp_t gfp_mask);
```

## blk_release_queue

函数签名：
```c
void blk_release_queue(struct kobject *kobj);
```

## blk_register_queue

函数签名：
```c
int blk_register_queue(struct gendisk *disk);
```

## blk_unregister_queue

函数签名：
```c
void blk_unregister_queue(struct gendisk *disk);
```

## blk_set_stacking_limits

函数签名：
```c
void blk_set_stacking_limits(struct queue_limits *lim);
```

## blk_queue_bounce_limit

函数签名：
```c
void blk_queue_bounce_limit(struct request_queue *q, enum blk_bounce bounce);
```

## blk_queue_max_hw_sectors

函数签名：
```c
void blk_queue_max_hw_sectors(struct request_queue *q, unsigned int max_hw_sectors);
```

## blk_queue_chunk_sectors

函数签名：
```c
void blk_queue_chunk_sectors(struct request_queue *q, unsigned int chunk_sectors);
```

## blk_queue_max_discard_sectors

函数签名：
```c
void blk_queue_max_discard_sectors(struct request_queue *q, unsigned int max_discard_sectors);
```

## blk_queue_max_secure_erase_sectors

函数签名：
```c
void blk_queue_max_secure_erase_sectors(struct request_queue *q, unsigned int max_sectors);
```

## blk_queue_max_write_zeroes_sectors

函数签名：
```c
void blk_queue_max_write_zeroes_sectors(struct request_queue *q, unsigned int max_write_zeroes_sectors);
```

## blk_queue_max_zone_append_sectors

函数签名：
```c
void blk_queue_max_zone_append_sectors(struct request_queue *q, unsigned int max_zone_append_sectors);
```

## blk_queue_max_segments

函数签名：
```c
void blk_queue_max_segments(struct request_queue *q, unsigned short max_segments);
```

## blk_queue_max_discard_segments

函数签名：
```c
void blk_queue_max_discard_segments(struct request_queue *q, unsigned short max_segments);
```

## blk_queue_max_segment_size

函数签名：
```c
void blk_queue_max_segment_size(struct request_queue *q, unsigned int max_size);
```

## blk_queue_logical_block_size

函数签名：
```c
void blk_queue_logical_block_size(struct request_queue *q, unsigned int size);
```

## blk_queue_physical_block_size

函数签名：
```c
void blk_queue_physical_block_size(struct request_queue *q, unsigned int size);
```

## blk_queue_zone_write_granularity

函数签名：
```c
void blk_queue_zone_write_granularity(struct request_queue *q, unsigned int size);
```

## blk_queue_alignment_offset

函数签名：
```c
void blk_queue_alignment_offset(struct request_queue *q, unsigned int offset);
```

## blk_limits_io_min

函数签名：
```c
void blk_limits_io_min(struct queue_limits *limits, unsigned int min);
```

## blk_queue_io_min

函数签名：
```c
void blk_queue_io_min(struct request_queue *q, unsigned int min);
```

## blk_limits_io_opt

函数签名：
```c
void blk_limits_io_opt(struct queue_limits *limits, unsigned int opt);
```

## blk_queue_io_opt

函数签名：
```c
void blk_queue_io_opt(struct request_queue *q, unsigned int opt);
```

## blk_stack_limits

函数签名：
```c
int blk_stack_limits(struct queue_limits *t, struct queue_limits *b, sector_t start);
```

## disk_stack_limits

函数签名：
```c
void disk_stack_limits(struct gendisk *disk, struct block_device *bdev, sector_t offset);
```

## blk_queue_update_dma_pad

函数签名：
```c
void blk_queue_update_dma_pad(struct request_queue *q, unsigned int mask);
```

## blk_queue_segment_boundary

函数签名：
```c
void blk_queue_segment_boundary(struct request_queue *q, unsigned long mask);
```

## blk_queue_virt_boundary

函数签名：
```c
void blk_queue_virt_boundary(struct request_queue *q, unsigned long mask);
```

## blk_queue_dma_alignment

函数签名：
```c
void blk_queue_dma_alignment(struct request_queue *q, int mask);
```

## blk_queue_update_dma_alignment

函数签名：
```c
void blk_queue_update_dma_alignment(struct request_queue *q, int mask);
```

## blk_set_queue_depth

函数签名：
```c
void blk_set_queue_depth(struct request_queue *q, unsigned int depth);
```

## blk_queue_write_cache

函数签名：
```c
void blk_queue_write_cache(struct request_queue *q, bool wc, bool fua);
```

## blk_queue_required_elevator_features

函数签名：
```c
void blk_queue_required_elevator_features(struct request_queue *q, unsigned int features);
```

## blk_queue_can_use_dma_merging

函数签名：
```c
bool blk_queue_can_use_dma_map_merging(struct request_queue *q, struct device *dev);
```

## disk_set_zoned

函数签名：
```c
void disk_set_zoned(struct gendisk *disk, enum blk_zoned_model model);
```

## blkdev_issue_flush

函数签名：
```c
int blkdev_issue_flush(struct block_device *bdev);
```

## blkdev_issue_discard

函数签名：
```c
int blkdev_issue_discard(struct block_device *bdev, sector_t sector, sector_t nr_sects, gfp_t gfp_mask);
```

## __blkdev_issue_zeroout

函数签名：
```c
int __blkdev_issue_zeroout(struct block_device *bdev, sector_t sector, sector_t nr_sects, gfp_t gfp_mask, struct bio **biop, unsigned flags);
```

## blkdev_issue_zeroout

函数签名：
```c
int blkdev_issue_zeroout(struct block_device *bdev, sector_t sector, sector_t nr_sects, gfp_t gfp_mask, unsigned flags);
```

## blk_rq_count_integrity_sg

函数签名：
```c
int blk_rq_count_integrity_sg(struct request_queue *q, struct bio *bio);
```

## blk_rq_map_integrity_sg

函数签名：
```c
int blk_rq_map_integrity_sg(struct request_queue *q, struct bio *bio, struct scatterlist *sglist);
```

## blk_integrity_compare

函数签名：
```c
int blk_integrity_compare(struct gendisk *gd1, struct gendisk *gd2);
```

## blk_integrity_register

函数签名：
```c
void blk_integrity_register(struct gendisk *disk, struct blk_integrity *template);
```

## blk_integrity_unregister

函数签名：
```c
void blk_integrity_unregister(struct gendisk *disk);
```

## blk_trace_ioctl

函数签名：
```c
int blk_trace_ioctl(struct block_device *bdev, unsigned cmd, char __user *arg);
```

## blk_trace_shutdown

函数签名：
```c
void blk_trace_shutdown(struct request_queue *q);
```

## blk_add_trace_rq

函数签名：
```c
void blk_add_trace_rq(struct request *rq, blk_status_t error, unsigned int nr_bytes, u32 what, u64 cgid);
```

## blk_add_trace_bio

函数签名：
```c
void blk_add_trace_bio(struct request_queue *q, struct bio *bio, u32 what, int error);
```

## blk_add_trace_bio_remap

函数签名：
```c
void blk_add_trace_bio_remap(void *ignore, struct bio *bio, dev_t dev, sector_t from);
```

## blk_add_trace_rq_remap

函数签名：
```c
void blk_add_trace_rq_remap(void *ignore, struct request *rq, dev_t dev, sector_t from);
```

## disk_release

函数签名：
```c
void disk_release(struct device *dev);
```

## __register_blkdev

函数签名：
```c
int __register_blkdev(unsigned int major, const char *name, void (*probe)(dev_t devt));
```

## device_add_disk

函数签名：
```c
int device_add_disk(struct device *parent, struct gendisk *disk, const struct attribute_group **groups);
```

## blk_mark_disk_dead

函数签名：
```c
void blk_mark_disk_dead(struct gendisk *disk);
```

## del_gendisk

函数签名：
```c
void del_gendisk(struct gendisk *disk);
```

## invalidate_disk

函数签名：
```c
void invalidate_disk(struct gendisk *disk);
```

## put_disk

函数签名：
```c
void put_disk(struct gendisk *disk);
```

## set_disk_ro

函数签名：
```c
void set_disk_ro(struct gendisk *disk, bool read_only);
```

## freeze_bdev

函数签名：
```c
int freeze_bdev(struct block_device *bdev);
```

## thaw_bdev

函数签名：
```c
int thaw_bdev(struct block_device *bdev);
```

## bd_prepare_to_claim

函数签名：
```c
int bd_prepare_to_claim(struct block_device *bdev, void *holder);
```

## bd_abort_claiming

函数签名：
```c
void bd_abort_claiming(struct block_device *bdev, void *holder);
```

## blkdev_get_by_dev

函数签名：
```c
struct block_device *blkdev_get_by_dev(dev_t dev, fmode_t mode, void *holder);
```

## blkdev_get_by_path

函数签名：
```c
struct block_device *blkdev_get_by_path(const char *path, fmode_t mode, void *holder);
```

## lookup_bdev

函数签名：
```c
int lookup_bdev(const char *pathname, dev_t *dev);
```

