import logging
from fprint cimport *
from cpython cimport PyBytes_FromStringAndSize
from posix.types cimport suseconds_t, time_t
from posix.time cimport timeval
from libc.stdlib cimport malloc, free


log = logging.Logger(__name__)


cdef class Driver:
    cdef fp_driver *ptr

    def __nonzero__(self):
        return self.ptr != NULL

    @staticmethod
    cdef new(fp_driver *ptr):
        d = Driver()
        d.ptr = ptr
        return d

    @property
    def name(self):
        if self.ptr != NULL:
            return <bytes> fp_driver_get_name(self.ptr)

    @property
    def full_name(self):
        if self.ptr != NULL:
            return <bytes> fp_driver_get_full_name(self.ptr)

    @property
    def driver_id(self):
        if self.ptr != NULL:
            return fp_driver_get_driver_id(self.ptr)

    @property
    def scan_type(self):
        if self.ptr != NULL:
            return fp_driver_get_scan_type(self.ptr)

    @property
    def supports_imaging(self):
        if self.ptr != NULL:
            return <bint> fp_driver_supports_imaging(self.ptr)


cdef class PrintData:
    cdef fp_print_data *ptr

    def __dealloc__(self):
        if self.ptr != NULL:
            fp_print_data_free(self.ptr)

    def __nonzero__(self):
        return self.ptr != NULL

    @staticmethod
    def load(Device d, fp_finger finger):
        pd = PrintData()
        if fp_print_data_load(d.ptr, finger, &pd.ptr) > 0:
            return pd

    @staticmethod
    def from_data(bytes data):
        pd = PrintData()
        pd.ptr = fp_print_data_from_data(data, len(data))
        if pd.ptr != NULL:
            return pd

    @property
    def driver_id(self):
        if self.ptr != NULL:
            return fp_print_data_get_driver_id(self.ptr)

    @property
    def devtype(self):
        if self.ptr != NULL:
            return fp_print_data_get_devtype(self.ptr)

    @property
    def data(self):
        cdef unsigned char *buf
        cdef int buf_len
        if self.ptr != NULL:
            buf_len = fp_print_data_get_data(self.ptr, &buf)
            return PyBytes_FromStringAndSize(<char *>buf, buf_len)

    def save(self, fp_finger finger):
        if self.ptr != NULL:
            return fp_print_data_save(self.ptr, finger)

    def delete(self, Device d, fp_finger finger):
        if self.ptr != NULL:
            return fp_print_data_delete(d.ptr, finger)


cdef class Minutia:
    cdef fp_minutia *ptr

    def __nonzero__(self):
        return self.ptr != NULL

    @staticmethod
    cdef new(fp_minutia *ptr):
        m = Minutia()
        m.ptr = ptr
        return m

    @property
    def coords(self):
        cdef int x
        cdef int y
        if self.ptr != NULL:
            result = fp_minutia_get_coords(self.ptr, &x, &y)
            if result == 0:
                return (x, y)
        return (None, None)


cdef class Image:
    cdef fp_img *ptr

    def __nonzero__(self):
        return self.ptr != NULL

    @staticmethod
    cdef new(fp_img *ptr):
        i = Image()
        i.ptr = ptr
        return i

    def __dealloc__(self):
        if self.ptr != NULL:
            fp_img_free(self.ptr)

    @property
    def width(self):
        if self.ptr != NULL:
            return fp_img_get_width(self.ptr)

    @property
    def height(self):
        if self.ptr != NULL:
            return fp_img_get_height(self.ptr)

    @property
    def data(self):
        if self.ptr != NULL:
            return <bytes> fp_img_get_data(self.ptr)

    @property
    def minutiae(self):
        cdef int nr_minutiae = 0
        cdef fp_minutia **minutiae
        if self.ptr != NULL:
            minutiae = fp_img_get_minutiae(self.ptr, &nr_minutiae)
            if minutiae != NULL:
                return tuple(Minutia.new(minutiae[i]) for i in xrange(nr_minutiae))

    def save_to_file(self, str path):
        cdef bytes py_bytes = path.encode()
        cdef char* c_string = py_bytes
        if self.ptr != NULL:
            return fp_img_save_to_file(self.ptr, c_string)

    def standartize(self):
        if self.ptr != NULL:
            fp_img_standardize(self.ptr)

    def binarize(self):
        cdef fp_img *img
        if self.ptr != NULL:
            img = fp_img_binarize(self.ptr)
            if img != NULL:
                return Image.new(img)


cdef class DiscoveredDevices:
    cdef fp_dscv_dev **devices
    cdef int number_devices

    def __cinit__(self):
        self.devices = fp_discover_devs()
        cdef int i = 0
        while self.devices[i] != NULL:
            i += 1
        self.number_devices = i

    def __dealloc__(self):
        fp_dscv_devs_free(self.devices)

    def __getitem__(self, int i):
        cdef fp_dscv_dev *dd
        if i < self.number_devices:
            dd = self.devices[i]
            return DiscoverdDevice.new(dd)
        else:
            raise IndexError()

    def __len__(self):
        return self.number_devices


cdef class DiscoverdDevice:
    cdef fp_dscv_dev *ptr

    def __nonzero__(self):
        return self.ptr != NULL

    @staticmethod
    cdef new(fp_dscv_dev *ptr):
        dd = DiscoverdDevice()
        dd.ptr = ptr
        return dd

    @staticmethod
    def discover():
        return DiscoveredDevices()

    @property
    def driver_id(self):
        if self.ptr != NULL:
            return fp_dscv_dev_get_driver_id(self.ptr)

    @property
    def driver(self):
        cdef fp_driver *drv
        if self.ptr != NULL:
            drv = fp_dscv_dev_get_driver(self.ptr)
            if drv != NULL:
                return Driver.new(drv)

    @property
    def devtype(self):
        if self.ptr != NULL:
            return fp_dscv_dev_get_devtype(self.ptr)

    def supports_print_data(self, PrintData pd):
        if self.ptr != NULL:
            return <bint> fp_dscv_dev_supports_print_data(self.ptr, pd.ptr)

    def open_device(self):
       return Device.open(self)


cdef class Device:
    cdef fp_dev *ptr

    def __nonzero__(self):
        return self.ptr != NULL

    @staticmethod
    cdef new(fp_dev *ptr):
        d = Device()
        d.ptr = ptr
        return d

    @staticmethod
    def open(DiscoverdDevice dd):
        cdef fp_dev *dev = fp_dev_open(dd.ptr)
        if dev != NULL:
            return Device.new(dev)
        else:
            raise RuntimeError("Cannot open device")

    def close(self):
        if self.ptr != NULL:
            fp_dev_close(self.ptr)

    @property
    def driver(self):
        cdef fp_driver *drv
        if self.ptr != NULL:
            drv = fp_dev_get_driver(self.ptr)
            if drv != NULL:
                return Driver.new(drv)

    @property
    def devtype(self):
        if self.ptr != NULL:
            return fp_dev_get_devtype(self.ptr)

    @property
    def number_enroll_stages(self):
        if self.ptr != NULL:
            return fp_dev_get_nr_enroll_stages(self.ptr)

    def supports_print_data(self, PrintData pd):
        if self.ptr != NULL:
            return <bint> fp_dev_supports_print_data(self.ptr, pd.ptr)

    def supports_imaging(self):
        if self.ptr != NULL:
            return <bint> fp_dev_supports_imaging(self.ptr)

    def supports_identification(self):
        if self.ptr != NULL:
            return <bint> fp_dev_supports_identification(self.ptr)

    def capture_image(self, int unconditional):
        if self.ptr != NULL:
            i = Image()
            fp_dev_img_capture(self.ptr, unconditional, &i.ptr)
            return i

    def image_width(self):
        if self.ptr != NULL:
            return fp_dev_get_img_width(self.ptr)

    def image_height(self):
        if self.ptr != NULL:
            return fp_dev_get_img_height(self.ptr)

    def enroll_finger_loop(self):
        if self.ptr != NULL:
            pd = PrintData()
            r = FP_ENROLL_RETRY
            while r != FP_ENROLL_COMPLETE:
                r = fp_enroll_finger(self.ptr, &pd.ptr)
                if r < 0:
                    raise RuntimeError("Internal I/O error while enrolling: %i" % r)
                if r == FP_ENROLL_COMPLETE:
                    log.debug("enroll complete")
                if r == FP_ENROLL_FAIL:
                    print("Failed. Enrollment process reset.")
                    return None
                if r == FP_ENROLL_PASS:
                    log.debug("enroll PASS")
                    pass
                if r == FP_ENROLL_RETRY:
                    log.debug("enroll RETRY")
                    pass
                if r == FP_ENROLL_RETRY_TOO_SHORT:
                    log.debug("enroll RETRY_SHORT")
                    pass
                if r == FP_ENROLL_RETRY_CENTER_FINGER:
                    log.debug("enroll RETRY_CENTER")
                    pass
                if r == FP_ENROLL_RETRY_REMOVE_FINGER:
                    log.debug("enroll RETRY_REMOVE")
                    pass
            return pd

    def enrol_finger_img(self):
        if self.ptr != NULL:
            img = Image()
            pd = PrintData()
            result = fp_enroll_finger_img(self.ptr, &pd.ptr, &img.ptr)
            return (result, pd, img)

    def enrol_finger(self):
        if self.ptr != NULL:
            pd = PrintData()
            result = fp_enroll_finger(self.ptr, &pd.ptr)
            return (result, pd)

    def verify_finger_loop(self, PrintData pd):
        if self.ptr != NULL:
            while True:
                r = fp_verify_finger(self.ptr, pd.ptr)
                if r < 0:
                    raise RuntimeError("verify error: %i" % r)
                if r == FP_VERIFY_NO_MATCH:
                    return False
                if r == FP_VERIFY_MATCH:
                    return True
                if r == FP_VERIFY_RETRY:
                    pass
                if r == FP_VERIFY_RETRY_TOO_SHORT:
                    pass
                if r == FP_VERIFY_RETRY_CENTER_FINGER:
                    pass
                if r == FP_VERIFY_RETRY_REMOVE_FINGER:
                    pass

    def verify_finger_img(self, PrintData pd):
        if self.ptr != NULL:
            img = Image()
            pd = PrintData()
            result = fp_verify_finger_img(self.ptr, pd.ptr, &img.ptr)
            return result, img

    def verify_finger(self, PrintData pd):
        if self.ptr != NULL:
            pd = PrintData()
            result = fp_verify_finger(self.ptr, pd.ptr)
            return result

    def identify_finger_img(self, tuple gallery):
        if not all(isinstance(item, PrintData) for item in gallery):
            raise ValueError("gallery param shoud be a tuple of PrintData instances")
        if not all((<PrintData>item).ptr != NULL for item in gallery):
            raise ValueError("gallery param contains items with NULL pointer")

        cdef size_t off = 0
        cdef size_t n = len(gallery) + 1
        cdef fp_print_data **arr = <fp_print_data **>malloc(n * sizeof(void*))

        arr[n - 1] = NULL
        for idx, pd in enumerate(gallery):
            arr[idx] = (<PrintData>pd).ptr

        try:
            if self.ptr != NULL:
                i = Image()
                if fp_identify_finger_img(self.ptr, arr, &off, &i.ptr) == FP_VERIFY_MATCH:
                    return (gallery[off], i)
            return (None, None)
        finally:
            free(arr)

    def identify_finger(self, tuple gallery):
        if not all(isinstance(item, PrintData) for item in gallery):
            raise ValueError("gallery param shoud be a tuple of PrintData instances")
        if not all((<PrintData>item).ptr != NULL for item in gallery):
            raise ValueError("gallery param contains items with NULL pointer")

        cdef size_t off = 0
        cdef size_t n = len(gallery) + 1
        cdef fp_print_data **arr = <fp_print_data **>malloc(n * sizeof(void*))

        arr[n - 1] = NULL
        for idx, pd in enumerate(gallery):
            arr[idx] = (<PrintData>pd).ptr

        try:
            if self.ptr != NULL:
                if fp_identify_finger(self.ptr, arr, &off) == FP_VERIFY_MATCH:
                    return gallery[off]
            return None
        finally:
            free(arr)


def init():
    if fp_init() < 0:
        raise RuntimeError("Failed to init libfprint")


def exit():
    fp_exit()
