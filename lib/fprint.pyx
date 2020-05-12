# cython: language_level=3
import logging
import asyncio
import asyncio_glib
from lib.fprint cimport *
from libc.stdint cimport uintptr_t
from cpython cimport PyBytes_FromStringAndSize
from posix.types cimport suseconds_t, time_t
from posix.time cimport timeval
from libc.stdlib cimport malloc, free


# log = logging.Logger(__name__)


cpdef init_context():
    # For proper work, python and libfprint should work on the same event loop
    asyncio.set_event_loop_policy(asyncio_glib.GLibEventLoopPolicy())
    ctx = Context()
    


cdef class Context:
    cdef FpContext *ptr

    def __nonzero__(self):
        return self.ptr != NULL

    def __init__(self):
        self.ptr = fp_context_new()


    def devices(self):
        return Devices.new(fp_context_get_devices(self.ptr))

    def first_device(self):
        return self.devices().first

    def open_first_device(self):
        dev = self.first_device()



# cdef class Driver:
#     cdef FpDriver *ptr

#     def __nonzero__(self):
#         return self.ptr != NULL

#     @staticmethod
#     cdef new(FpDriver *ptr):
#         d = Driver()
#         d.ptr = ptr
#         return d

#     @property
#     def name(self):
#         if self.ptr != NULL:
#             return <bytes> fp_driver_get_name(self.ptr)

#     @property
#     def full_name(self):
#         if self.ptr != NULL:
#             return <bytes> fp_driver_get_full_name(self.ptr)

#     @property
#     def driver_id(self):
#         if self.ptr != NULL:
#             return fp_driver_get_driver_id(self.ptr)

#     @property
#     def scan_type(self):
#         if self.ptr != NULL:
#             return fp_driver_get_scan_type(self.ptr)

#     @property
#     def supports_imaging(self):
#         if self.ptr != NULL:
#             return <bint> fp_driver_supports_imaging(self.ptr)



# cdef class PrintData:
#     cdef fp_print_data *ptr

#     def __dealloc__(self):
#         if self.ptr != NULL:
#             fp_print_data_free(self.ptr)

#     def __nonzero__(self):
#         return self.ptr != NULL

#     @staticmethod
#     def load(Device d, fp_finger finger):
#         pd = PrintData()
#         if fp_print_data_load(d.ptr, finger, &pd.ptr) > 0:
#             return pd

#     @staticmethod
#     def from_data(bytes data):
        
#         pd = PrintData()
#         pd.ptr = fp_print_data_from_data(data, len(data))
#         if pd.ptr != NULL:
#             return pd

#     @property
#     def driver_id(self):
#         if self.ptr != NULL:
#             return fp_print_data_get_driver_id(self.ptr)

#     @property
#     def devtype(self):
#         if self.ptr != NULL:
#             return fp_print_data_get_devtype(self.ptr)

#     @property
#     def data(self):
#         cdef unsigned char *buf
#         cdef int buf_len
#         if self.ptr != NULL:
#             buf_len = fp_print_data_get_data(self.ptr, &buf)
#             return PyBytes_FromStringAndSize(<char *>buf, buf_len)

#     def save(self, fp_finger finger):
#         if self.ptr != NULL:
#             return fp_print_data_save(self.ptr, finger)

#     def delete(self, Device d, fp_finger finger):
#         if self.ptr != NULL:
#             return fp_print_data_delete(d.ptr, finger)



# cdef class Minutia:
#     cdef fp_minutia *ptr

#     def __nonzero__(self):
#         return self.ptr != NULL

#     @staticmethod
#     cdef new(fp_minutia *ptr):
#         m = Minutia()
#         m.ptr = ptr
#         return m

#     @property
#     def coords(self):
#         cdef int x
#         cdef int y
#         if self.ptr != NULL:
#             result = fp_minutia_get_coords(self.ptr, &x, &y)
#             if result == 0:
#                 return (x, y)
#         return (None, None)



# cdef class Image:
#     cdef fp_img *ptr

#     def __nonzero__(self):
#         return self.ptr != NULL

#     @staticmethod
#     cdef new(fp_img *ptr):
#         i = Image()
#         i.ptr = ptr
#         return i

#     def __dealloc__(self):
#         if self.ptr != NULL:
#             fp_img_free(self.ptr)

#     @property
#     def width(self):
#         if self.ptr != NULL:
#             return fp_img_get_width(self.ptr)

#     @property
#     def height(self):
#         if self.ptr != NULL:
#             return fp_img_get_height(self.ptr)

#     @property
#     def data(self):
#         if self.ptr != NULL:
#             return <bytes> fp_img_get_data(self.ptr)

#     @property
#     def minutiae(self):
#         cdef int nr_minutiae = 0
#         cdef fp_minutia **minutiae
#         if self.ptr != NULL:
#             minutiae = fp_img_get_minutiae(self.ptr, &nr_minutiae)
#             if minutiae != NULL:
#                 return tuple(Minutia.new(minutiae[i]) for i in xrange(nr_minutiae))

#     def save_to_file(self, str path):
#         cdef bytes py_bytes = path.encode()
#         cdef char* c_string = py_bytes
#         if self.ptr != NULL:
#             return fp_img_save_to_file(self.ptr, c_string)

#     def standartize(self):
#         if self.ptr != NULL:
#             fp_img_standardize(self.ptr)

#     def binarize(self):
#         cdef fp_img *img
#         if self.ptr != NULL:
#             img = fp_img_binarize(self.ptr)
#             if img != NULL:
#                 return Image.new(img)



cdef class Devices:
    cdef GPtrArray *ptr

    @staticmethod
    cdef new(GPtrArray *ptr):
        self = Devices()
        self.ptr = ptr
        return self

    def __nonzero__(self):
        return self.ptr != NULL and self.ptr.len > 0

    def __getitem__(self, guint i):
        cdef FpDevice *dev
        cdef GPtrArray arr

        if self.ptr != NULL and i < self.ptr.len:
            dev = <FpDevice *> self.ptr.pdata[i]
            return Device.new(dev)
        else:
            raise IndexError("Device with '{}' index does not exists".format(i))

    def __len__(self):
        return self.ptr != NULL and self.ptr.len or 0


    @property
    def first(self):
        return self and self[0] or None


cdef class Device:
    cdef FpDevice *ptr

    @staticmethod
    cdef new(FpDevice *ptr):
        self = Device()
        self.ptr = ptr
        return self

    def __nonzero__(self):
        return self.ptr != NULL

    def __repr__(self):
        return "Device<ptr={}>".format(<uintptr_t>self.ptr)

    def __str__(self):
        return "Device<id={} name={} driver={}>".format(
            self.device_id, self.device_name, self.driver_name)

    @property
    def device_id(self):
        if self.ptr != NULL:
            return <bytes> fp_device_get_device_id(self.ptr)

    @property
    def device_name(self):
        if self.ptr != NULL:
            return <bytes> fp_device_get_name(self.ptr)

    @property
    def driver_name(self):
        if self.ptr != NULL:
            return <bytes> fp_device_get_driver(self.ptr)
           
    @property
    def is_open(self):
        if self.ptr != NULL:
            <bint> fp_device_is_open(self.ptr)
        else:
            return False

    @property
    def scan_type(self):
        if self.ptr != NULL:
            return fp_device_get_scan_type(self.ptr)

    @property
    def device_type(self):
        if self.ptr != NULL:
            return fp_device_type_get_type()

    @property
    def retry_type(self):
        if self.ptr != NULL:
            return fp_device_retry_get_type()

    @property
    def error_type(self):
        if self.ptr != NULL:
            return fp_device_error_get_type()
    
    @property
    def supports_identify(self):
        if self.ptr != NULL:
            return <bint> fp_device_supports_identify(self.ptr)
        else:
            return False
    
    @property
    def supports_capture(self):
        if self.ptr != NULL:
            return <bint> fp_device_supports_capture(self.ptr)
        else:
            return False

    @property
    def has_storage(self):
        if self.ptr != NULL:
            return <bint> fp_device_has_storage(self.ptr)
        else:
            return False

    @property
    def number_enroll_stages(self):
        if self.ptr != NULL:
            return fp_device_get_nr_enroll_stages(self.ptr)
        else:
            return 0

    async def open(self):
        fp_device_open(
            self.ptr,
            NULL,
            # <GAsyncReadyCallback> callback,
            NULL,
            NULL)

    # async def close(self):
    #     fp_device_close(
    #         self.ptr,
    #         NULL,
    #         <GAsyncReadyCallback> callback,
    #         NULL)

    # async def enroll(self):
    #     fp_device_enroll(
    #         self.ptr,
    #         FpPrint *template_print,
    #         NULL,
    #         FpEnrollProgress progress_cb,
    #         gpointer progress_data,
    #         GDestroyNotify progress_destroy,
    #         <GAsyncReadyCallback> callback,
    #         NULL)

    # async def verify(self):
    #     fp_device_verify(
    #         self.ptr,
    #         FpPrint *enrolled_print,
    #         NULL,
    #         FpMatchCb match_cb,
    #         gpointer match_data,
    #         GDestroyNotify match_destroy,
    #         <GAsyncReadyCallback> callback,
    #         NULL)

    # async def identify(self):
    #     fp_device_identify(
    #         self.ptr,
    #         GPtrArray *prints,
    #         NULL,
    #         FpMatchCb match_cb,
    #         gpointer match_data,
    #         GDestroyNotify match_destroy,
    #         <GAsyncReadyCallback> callback,
    #         NULL)

    # async def capture(self, wait_for_finger=False,):
    #     fp_device_capture(
    #         self.ptr,
    #         <bint> wait_for_finger,
    #         NULL,
    #         <GAsyncReadyCallback> callback,
    #         NULL)

    # async def delete_print(self, Print print):
    #     fp_device_delete_print(
    #         self.ptr,
    #         FpPrint *enrolled_print,
    #         NULL,
    #         <GAsyncReadyCallback> callback,
    #         NULL)


    # async def list_prints(self):
    #     fp_device_list_prints(
    #         self.ptr,
    #         NULL,
    #         <GAsyncReadyCallback> callback,
    #         NULL)




# fp_device_retry_quark()
# fp_device_error_quark()


# (

# (
# (

# fp_device_open_finish(
# fp_device_close_finish(
# fp_device_enroll_finish(
# fp_device_verify_finish(
# fp_device_identify_finish(
# fp_device_capture_finish(
# fp_device_delete_print_finish(
# fp_device_list_prints_finish(
# fp_device_open_sync(
# fp_device_close_sync(
# fp_device_enroll_sync(
# fp_device_verify_sync(
# fp_device_identify_sync(
# fp_device_capture_sync(
# fp_device_delete_print_sync(
# fp_device_list_prints_sync(


# 
# cdef class Device:
#     cdef FpDevice *ptr


#     def supports_print_data(self, PrintData pd):
#         if self.ptr != NULL:
#             return <bint> fp_dev_supports_print_data(self.ptr, pd.ptr)

#     def supports_imaging(self):
#         if self.ptr != NULL:
#             return <bint> fp_dev_supports_imaging(self.ptr)

#     def supports_identification(self):
#         if self.ptr != NULL:
#             return <bint> fp_dev_supports_identification(self.ptr)

#     def capture_image(self, int unconditional):
#         if self.ptr != NULL:
#             i = Image()
#             fp_dev_img_capture(self.ptr, unconditional, &i.ptr)
#             return i

#     def image_width(self):
#         if self.ptr != NULL:
#             return fp_dev_get_img_width(self.ptr)

#     def image_height(self):
#         if self.ptr != NULL:
#             return fp_dev_get_img_height(self.ptr)

#     def enroll_finger_loop(self):
#         if self.ptr != NULL:
#             pd = PrintData()
#             r = FP_ENROLL_RETRY
#             while r != FP_ENROLL_COMPLETE:
#                 r = fp_enroll_finger(self.ptr, &pd.ptr)
#                 if r < 0:
#                     raise RuntimeError("Internal I/O error while enrolling: %i" % r)
#                 if r == FP_ENROLL_COMPLETE:
#                     log.debug("enroll complete")
#                 if r == FP_ENROLL_FAIL:
#                     print("Failed. Enrollment process reset.")
#                     return None
#                 if r == FP_ENROLL_PASS:
#                     log.debug("enroll PASS")
#                     pass
#                 if r == FP_ENROLL_RETRY:
#                     log.debug("enroll RETRY")
#                     pass
#                 if r == FP_ENROLL_RETRY_TOO_SHORT:
#                     log.debug("enroll RETRY_SHORT")
#                     pass
#                 if r == FP_ENROLL_RETRY_CENTER_FINGER:
#                     log.debug("enroll RETRY_CENTER")
#                     pass
#                 if r == FP_ENROLL_RETRY_REMOVE_FINGER:
#                     log.debug("enroll RETRY_REMOVE")
#                     pass
#             return pd

#     def enrol_finger_img(self):
#         if self.ptr != NULL:
#             img = Image()
#             pd = PrintData()
#             result = fp_enroll_finger_img(self.ptr, &pd.ptr, &img.ptr)
#             return (result, pd, img)

#     def enrol_finger(self):
#         if self.ptr != NULL:
#             pd = PrintData()
#             result = fp_enroll_finger(self.ptr, &pd.ptr)
#             return (result, pd)

#     def verify_finger_loop(self, PrintData pd):
#         if self.ptr != NULL:
#             while True:
#                 r = fp_verify_finger(self.ptr, pd.ptr)
#                 if r < 0:
#                     raise RuntimeError("verify error: %i" % r)
#                 if r == FP_VERIFY_NO_MATCH:
#                     return False
#                 if r == FP_VERIFY_MATCH:
#                     return True
#                 if r == FP_VERIFY_RETRY:
#                     pass
#                 if r == FP_VERIFY_RETRY_TOO_SHORT:
#                     pass
#                 if r == FP_VERIFY_RETRY_CENTER_FINGER:
#                     pass
#                 if r == FP_VERIFY_RETRY_REMOVE_FINGER:
#                     pass

#     def verify_finger_img(self, PrintData pd):
#         if self.ptr != NULL:
#             img = Image()
#             pd = PrintData()
#             result = fp_verify_finger_img(self.ptr, pd.ptr, &img.ptr)
#             return result, img

#     def verify_finger(self, PrintData pd):
#         if self.ptr != NULL:
#             pd = PrintData()
#             result = fp_verify_finger(self.ptr, pd.ptr)
#             return result

#     def identify_finger_img(self, tuple gallery):
#         if not all(isinstance(item, PrintData) for item in gallery):
#             raise ValueError("gallery param shoud be a tuple of PrintData instances")
#         if not all((<PrintData>item).ptr != NULL for item in gallery):
#             raise ValueError("gallery param contains items with NULL pointer")

#         cdef size_t off = 0
#         cdef size_t n = len(gallery) + 1
#         cdef fp_print_data **arr = <fp_print_data **>malloc(n * sizeof(void*))

#         arr[n - 1] = NULL
#         for idx, pd in enumerate(gallery):
#             arr[idx] = (<PrintData>pd).ptr

#         try:
#             if self.ptr != NULL:
#                 i = Image()
#                 if fp_identify_finger_img(self.ptr, arr, &off, &i.ptr) == FP_VERIFY_MATCH:
#                     return (gallery[off], i)
#             return (None, None)
#         finally:
#             free(arr)

#     def identify_finger(self, tuple gallery):
#         if not all(isinstance(item, PrintData) for item in gallery):
#             raise ValueError("gallery param shoud be a tuple of PrintData instances")
#         if not all((<PrintData>item).ptr != NULL for item in gallery):
#             raise ValueError("gallery param contains items with NULL pointer")

#         cdef size_t off = 0
#         cdef size_t n = len(gallery) + 1
#         cdef fp_print_data **arr = <fp_print_data **>malloc(n * sizeof(void*))

#         arr[n - 1] = NULL
#         for idx, pd in enumerate(gallery):
#             arr[idx] = (<PrintData>pd).ptr

#         try:
#             if self.ptr != NULL:
#                 if fp_identify_finger(self.ptr, arr, &off) == FP_VERIFY_MATCH:
#                     return gallery[off]
#             return None
#         finally:
#             free(arr)


# def init():
#     if fp_init() < 0:
#         raise RuntimeError("Failed to init libfprint")


# def exit():
#     fp_exit()
