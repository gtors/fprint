from posix.time cimport timeval
from libc.stdint cimport uint32_t, uint16_t

cdef extern from "libfprint/fprint.h":

    struct fp_dscv_dev:
        pass

    struct fp_dscv_print:
        pass

    struct fp_dev:
        pass

    struct fp_driver:
        pass

    struct fp_print_data:
        pass

    struct fp_img:
        pass

    cpdef enum fp_finger:
        LEFT_THUMB = 1
        LEFT_INDEX 
        LEFT_MIDDLE
        LEFT_RING
        LEFT_LITTLE
        RIGHT_THUMB
        RIGHT_INDEX
        RIGHT_MIDDLE
        RIGHT_RING
        RIGHT_LITTLE

    cpdef enum fp_scan_type:
        FP_SCAN_TYPE_PRESS = 0
        FP_SCAN_TYPE_SWIPE

    const char *fp_driver_get_name(fp_driver *drv)
    const char *fp_driver_get_full_name(fp_driver *drv)
    uint16_t fp_driver_get_driver_id(fp_driver *drv)
    fp_scan_type fp_driver_get_scan_type(fp_driver *drv)

    fp_dscv_dev **fp_discover_devs()
    void fp_dscv_devs_free(fp_dscv_dev **devs)
    fp_driver *fp_dscv_dev_get_driver(fp_dscv_dev *dev)
    uint32_t fp_dscv_dev_get_devtype(fp_dscv_dev *dev)
    int fp_dscv_dev_supports_print_data(fp_dscv_dev *dev, fp_print_data *_print)
    int fp_dscv_dev_supports_dscv_print(fp_dscv_dev *dev, fp_dscv_print *_print)
    fp_dscv_dev *fp_dscv_dev_for_print_data(fp_dscv_dev **devs, fp_print_data *_print)
    fp_dscv_dev *fp_dscv_dev_for_dscv_print(fp_dscv_dev **devs, fp_dscv_print *_print)

    fp_dscv_print **fp_discover_prints()
    void fp_dscv_prints_free(fp_dscv_print **_prints)
    uint16_t fp_dscv_print_get_driver_id(fp_dscv_print *_print)
    uint32_t fp_dscv_print_get_devtype(fp_dscv_print *_print)
    fp_finger fp_dscv_print_get_finger(fp_dscv_print *_print)
    int fp_dscv_print_delete(fp_dscv_print *_print)

    fp_dev *fp_dev_open(fp_dscv_dev *ddev)
    void fp_dev_close(fp_dev *dev)
    fp_driver *fp_dev_get_driver(fp_dev *dev)
    int fp_dev_get_nr_enroll_stages(fp_dev *dev)
    uint32_t fp_dev_get_devtype(fp_dev *dev)
    int fp_dev_supports_print_data(fp_dev *dev, fp_print_data *data)
    int fp_dev_supports_dscv_print(fp_dev *dev, fp_dscv_print *_print)

    cpdef enum fp_capture_result:
        FP_CAPTURE_COMPLETE = 0
        FP_CAPTURE_FAIL

    int fp_dev_supports_imaging(fp_dev *dev)
    int fp_dev_img_capture(fp_dev *dev, int unconditional, fp_img **image)
    int fp_dev_get_img_width(fp_dev *dev)
    int fp_dev_get_img_height(fp_dev *dev)

    cpdef enum fp_enroll_result:
        FP_ENROLL_COMPLETE = 1
        FP_ENROLL_FAIL
        FP_ENROLL_PASS
        FP_ENROLL_RETRY = 100
        FP_ENROLL_RETRY_TOO_SHORT
        FP_ENROLL_RETRY_CENTER_FINGER
        FP_ENROLL_RETRY_REMOVE_FINGER

    int fp_enroll_finger_img(fp_dev *dev, fp_print_data **_print_data, fp_img **img)

    cpdef enum fp_verify_result:
        FP_VERIFY_NO_MATCH = 0
        FP_VERIFY_MATCH = 1
        FP_VERIFY_RETRY = fp_enroll_result.FP_ENROLL_RETRY
        FP_VERIFY_RETRY_TOO_SHORT = fp_enroll_result.FP_ENROLL_RETRY_TOO_SHORT
        FP_VERIFY_RETRY_CENTER_FINGER = fp_enroll_result.FP_ENROLL_RETRY_CENTER_FINGER
        FP_VERIFY_RETRY_REMOVE_FINGER = fp_enroll_result.FP_ENROLL_RETRY_REMOVE_FINGER

    int fp_verify_finger_img(fp_dev *dev, fp_print_data *enrolled_print, fp_img **img)

    int fp_dev_supports_identification(fp_dev *dev)
    int fp_identify_finger_img(fp_dev *dev, fp_print_data **_print_gallery, size_t *match_offset, fp_img **img)

    int fp_print_data_load(fp_dev *dev, fp_finger finger, fp_print_data **data)
    int fp_print_data_from_dscv_print(fp_dscv_print *_print, fp_print_data **data)
    int fp_print_data_save(fp_print_data *data, fp_finger finger)
    int fp_print_data_delete(fp_dev *dev, fp_finger finger)
    void fp_print_data_free(fp_print_data *data)
    size_t fp_print_data_get_data(fp_print_data *data, unsigned char **ret)
    fp_print_data *fp_print_data_from_data(unsigned char *buf, size_t buflen)
    uint16_t fp_print_data_get_driver_id(fp_print_data *data)
    uint32_t fp_print_data_get_devtype(fp_print_data *data)

    struct fp_minutia:
        int x
        int y
        int ex
        int ey
        int direction
        double reliability
        int type
        int appearing
        int feature_id
        int *nbrs
        int *ridge_counts
        int num_nbrs

    int fp_img_get_height(fp_img *img)
    int fp_img_get_width(fp_img *img)
    unsigned char *fp_img_get_data(fp_img *img)
    int fp_img_save_to_file(fp_img *img, char *path)
    void fp_img_standardize(fp_img *img)
    fp_img *fp_img_binarize(fp_img *img)
    fp_minutia **fp_img_get_minutiae(fp_img *img, int *nr_minutiae)
    void fp_img_free(fp_img *img)

    struct fp_pollfd:
        int fd
        short events

    int fp_handle_events_timeout(timeval *timeout)
    int fp_handle_events()
    size_t fp_get_pollfds(fp_pollfd **pollfds)
    int fp_get_next_timeout(timeval *tv)

    ctypedef void (*fp_pollfd_added_cb)(int fd, short events)
    ctypedef void (*fp_pollfd_removed_cb)(int fd)
    void fp_set_pollfd_notifiers(fp_pollfd_added_cb added_cb, fp_pollfd_removed_cb removed_cb)

    int fp_init()
    void fp_exit()
    void fp_set_debug(int level)

    ctypedef void (*fp_dev_open_cb)(fp_dev *dev, int status, void *user_data)
    int fp_async_dev_open(fp_dscv_dev *ddev, fp_dev_open_cb callback, void *user_data)

    ctypedef void (*fp_dev_close_cb)(fp_dev *dev, void *user_data)
    void fp_async_dev_close(fp_dev *dev, fp_dev_close_cb callback, void *user_data)

    ctypedef void (*fp_enroll_stage_cb)(fp_dev *dev, int result, fp_print_data *_print, fp_img *img, void *user_data)
    int fp_async_enroll_start(fp_dev *dev, fp_enroll_stage_cb callback, void *user_data)

    ctypedef void (*fp_enroll_stop_cb)(fp_dev *dev, void *user_data)
    int fp_async_enroll_stop(fp_dev *dev, fp_enroll_stop_cb callback, void *user_data)

    ctypedef void (*fp_verify_cb)(fp_dev *dev, int result, fp_img *img, void *user_data)
    int fp_async_verify_start(fp_dev *dev, fp_print_data *data, fp_verify_cb callback, void *user_data)

    ctypedef void (*fp_verify_stop_cb)(fp_dev *dev, void *user_data)
    int fp_async_verify_stop(fp_dev *dev, fp_verify_stop_cb callback, void *user_data)

    ctypedef void (*fp_identify_cb)(fp_dev *dev, int result, size_t match_offset, fp_img *img, void *user_data)
    int fp_async_identify_start(fp_dev *dev, fp_print_data **gallery, fp_identify_cb callback, void *user_data)

    ctypedef void (*fp_identify_stop_cb)(fp_dev *dev, void *user_data)
    int fp_async_identify_stop(fp_dev *dev, fp_identify_stop_cb callback, void *user_data)

    ctypedef void (*fp_capture_cb)(fp_dev *dev, int result, fp_img *img, void *user_data)
    int fp_async_capture_start(fp_dev *dev, int unconditional, fp_capture_cb callback, void *user_data)

    ctypedef void (*fp_capture_stop_cb)(fp_dev *dev, void *user_data)
    int fp_async_capture_stop(fp_dev *dev, fp_capture_stop_cb callback, void *user_data)
