# encoding:utf-8
# distutils: language = c++
# cython: nonecheck=True
# cython: profile=False
# cython: binding=True

# binding = true for inspect get callargs
from cpython cimport PyObject
from cpython.mem cimport PyMem_Malloc, PyMem_Realloc, PyMem_Free
from libc.stdlib cimport malloc, free
from libc.string cimport const_char
from libcpp cimport bool as cbool
from libcpp.memory cimport shared_ptr, make_shared

from headers.cMdAPI cimport CMdSpi, CMdApi, CreateFtdcMdApi

from headers.ThostFtdcUserApiStruct cimport CThostFtdcRspUserLoginField
from headers.ThostFtdcUserApiStruct cimport CThostFtdcRspInfoField
from headers.ThostFtdcUserApiStruct cimport CThostFtdcUserLogoutField
from headers.ThostFtdcUserApiStruct cimport CThostFtdcSpecificInstrumentField
from headers.ThostFtdcUserApiStruct cimport CThostFtdcDepthMarketDataField
from headers.ThostFtdcUserApiStruct cimport CThostFtdcFensUserInfoField
from headers.ThostFtdcUserApiStruct cimport CThostFtdcReqUserLoginField

import ctypes

from ctpwrapper import ApiStructure



# cdef class MdSpiWrapper:
#
#     # cdef CMdSpi *_spi
#     # https://github.com/ah-/kafka_arrow/blob/2b5dbfd61e594d505854b1e57aee8b8c2b16bd85/kafka_arrow.pyx
#
#     # c++ must call python self fu
#
#     def __cinit__(self):
#         pass
#         # self._spi = new CMdSpi(self)
#     def __dealloc__(self):
#         pass
#
#     def OnFrontConnected(self):
#
#         # 当客户端与交易后台通信连接断开时，该方法被调用。当发生这个情况后，API会自动重新连接，客户端可不做处理。
#         # @param nReason 错误原因
#         #  0x1001 网络读失败
#         #  0x1002 网络写失败
#         #  0x2001 接收心跳超时
#         #  0x2002 发送心跳失败
#         #  0x2003 收到错误报文
#         pass
#     def OnFrontDisconnected(self,int nReason):
#
#         # 心跳超时警告。当长时间未收到报文时，该方法被调用。
#         # @param nTimeLapse 距离上次接收报文的时间
#         pass
#     def OnHeartBeatWarning(self,int nTimeLapse):
#
#         # 登录请求响应
#         pass
#     cdef OnRspUserLogin(self,CThostFtdcRspUserLoginField *pRspUserLogin,
#                             CThostFtdcRspInfoField *pRspInfo,
#                             int nRequestID,
#                             cbool bIsLast):
#
#         # 登出请求响应
#         pass
#     cdef OnRspUserLogout(self,CThostFtdcUserLogoutField *pUserLogout,
#                              CThostFtdcRspInfoField *pRspInfo,
#                              int nRequestID,
#                              cbool bIsLast):
#
#         # 错误应答
#         pass
#     cdef OnRspError(self,CThostFtdcRspInfoField *pRspInfo,
#                         int nRequestID,
#                         cbool bIsLast):
#
#         # 订阅行情应答
#         pass
#     cdef OnRspSubMarketData(self,CThostFtdcSpecificInstrumentField *pSpecificInstrument,
#                                 CThostFtdcRspInfoField *pRspInfo,
#                                 int nRequestID,
#                                 cbool bIsLast):
#
#         # 取消订阅行情应答
#         pass
#     cdef OnRspUnSubMarketData(self,CThostFtdcSpecificInstrumentField *pSpecificInstrument,
#                                   CThostFtdcRspInfoField *pRspInfo,
#                                   int nRequestID,
#                                   cbool bIsLast):
#
#         # 深度行情通知
#         pass
#     cdef OnRtnDepthMarketData(self,CThostFtdcDepthMarketDataField *pDepthMarketData):
#
#         pass

cdef class MdApiWrapper:

    cdef CMdApi *_api

    cdef CMdSpi *_spi

    def __cinit__(self, const_char *pszFlowPath,
                  cbool bIsUsingUdp,
                  cbool bIsMulticast):

        self._api= CreateFtdcMdApi(pszFlowPath,bIsUsingUdp,bIsMulticast)
        if not self._api:
            raise MemoryError()

    def __dealloc__(self):

        if self._api is not NULL:
            self._api.RegisterSpi(NULL)
            self._api.Release()
            self._api= NULL

            self._spi =NULL #

    def __init__(self,pszFlowPath, bIsUsingUdp, bIsMulticast):
        pass

    @staticmethod
    def GetApiVersion():
        return CMdApi.GetApiVersion()

    def Init(self):
        if self._api is not NULL:

            # only for test
            self._spi = new CMdSpi(<PyObject *> self)
            self._api.RegisterSpi(self._spi)

            self._api.Init()

    def Join(self):
        if self._api is not NULL:
            self._api.Join()

    # def Release(self):
    #
    #     if self._api is not NULL:
    #         self._api.Release()

    # def RegisterSpi(self, spi):
    #     # todo fix this problems
    #     pass

        # cdef PyObject p_spi
        # p_spi = spi
        #
        # self._api.RegisterSpi(spi)

    def ReqUserLogin(self, pReqUserLoginField, nRequestID):
        """
        用户登录请求
        :return:
        """
        if self._api is not NULL:
            self._api.ReqUserLogin(<CThostFtdcReqUserLoginField *><size_t>ctypes.addressof(pReqUserLoginField),nRequestID)


    def ReqUserLogout(self, pUserLogout, nRequestID):
        """
        登出请求
        :return:
        """
        if self._api is not NULL:
            self._api.ReqUserLogout(<CThostFtdcUserLogoutField *><size_t>ctypes.addressof(pUserLogout),nRequestID)


    def GetTradingDay(self):
        """
        获取当前交易日
        @retrun 获取到的交易日
        @remark 只有登录成功后,才能得到正确的交易日
        :return:
        """
        cdef const_char *result

        if self._api is not NULL:
            result = self._api.GetTradingDay()
            return result

    def RegisterFront(self, char *pszFrontAddress):
        """
        注册前置机网络地址
        @param pszFrontAddress：前置机网络地址。
        @remark 网络地址的格式为：“protocol://ipaddress:port”，如：”tcp://127.0.0.1:17001”。
        @remark “tcp”代表传输协议，“127.0.0.1”代表服务器地址。”17001”代表服务器端口号。
        :return:
        """
        if self._api is not NULL:
            self._api.RegisterNameServer(pszFrontAddress)

    def RegisterNameServer(self,char *pszNsAddress):
        """
        注册名字服务器网络地址
        @param pszNsAddress：名字服务器网络地址。
        @remark 网络地址的格式为：“protocol://ipaddress:port”，如：”tcp://127.0.0.1:12001”。
        @remark “tcp”代表传输协议，“127.0.0.1”代表服务器地址。”12001”代表服务器端口号。
        @remark RegisterNameServer优先于RegisterFront
        :return:
        """
        if self._api is not NULL:
            self._api.RegisterNameServer(pszNsAddress)


    def RegisterFensUserInfo(self, pFensUserInfo):
        """
        注册名字服务器用户信息
        @param pFensUserInfo：用户信息。
        :return:
        """
        if self._api is not NULL:
            self._api.RegisterFensUserInfo(<CThostFtdcFensUserInfoField *><size_t>ctypes.addressof(pFensUserInfo))

    def SubscribeMarketData(self, pInstrumentID):
        """
         订阅行情。
        @param ppInstrumentID 合约ID
        @param nCount 要订阅/退订行情的合约个数

        #  https://www.quora.com/How-do-char-array-pointers-work-in-C++
        # http://docs.cython.org/en/latest/src/userguide/language_basics.html#integer-for-loops
        # https://stackoverflow.com/questions/15686890/how-to-allocate-array-of-pointers-for-strings-by-malloc-in-c

        :return:
        """
        cdef int count
        cdef int result
        cdef char **InstrumentIDs

        if self._api is not NULL:

            count = len(pInstrumentID)
            InstrumentIDs = <char **>malloc(sizeof(char*) *count)

            try:
                for i from 0<= i <count:
                    InstrumentIDs[i] = pInstrumentID[i]
                result = self._api.SubscribeMarketData(InstrumentIDs,count)
            finally:
                free(InstrumentIDs)
            return result

    def UnSubscribeMarketData(self, pInstrumentID):
        """
        退订行情。
        @param ppInstrumentID 合约ID
        @param nCount 要订阅/退订行情的合约个数
        :return:
        """
        cdef int count
        cdef int result
        cdef char **InstrumentIDs

        if self._api is not NULL:
            count = len(pInstrumentID)
            InstrumentIDs = <char **>malloc(sizeof(char*) *count)

            try:
                for i from 0<= i <count:
                    InstrumentIDs[i] = pInstrumentID[i]
                result = self._api.UnSubscribeMarketData(InstrumentIDs,count)
            finally:
                free(InstrumentIDs)
            return result

    def SubscribeForQuoteRsp(self, pInstrumentID):
        """
        订阅询价。
        :param pInstrumentID: 合约ID list

        :return:
        """

        cdef int count
        cdef int result
        cdef char **InstrumentIDs

        if self._api is not NULL:

            count = len(pInstrumentID)
            InstrumentIDs = <char **>malloc(sizeof(char*) *count)

            try:
                for i from 0<= i <count:
                    InstrumentIDs[i] = pInstrumentID[i]
                result = self._api.SubscribeForQuoteRsp(InstrumentIDs,count)
            finally:
                free(InstrumentIDs)
            return result

    def UnSubscribeForQuoteRsp(self, pInstrumentID):
        """
        退订询价。
        :param pInstrumentID: 合约ID list
        :return:
        """
        cdef int count
        cdef int result
        cdef char **InstrumentIDs

        if self._api is not NULL:

            count = len(pInstrumentID)
            InstrumentIDs = <char **>malloc(sizeof(char*) *count)
            try:
                for i from 0<= i <count:
                    InstrumentIDs[i] = pInstrumentID[i]

                result = self._api.UnSubscribeForQuoteRsp(InstrumentIDs,count)
            finally:
                free(InstrumentIDs)
            return result


# cdef extern int MdSpi_OnFrontConnected(self) except -1:
#     self.OnFrontConnected()
#
# cdef extern int MdSpi_OnFrontDisconnected(self, int nReason) except -1:
#     self.OnFrontDisconnected(nReason)
#
# cdef extern int MdSpi_OnHeartBeatWarning(self, int nTimeLapse) except -1:
#     self.OnHeartBeatWarning(nTimeLapse)
#
#
# cdef extern int MdSpi_OnRspUserLogin(self, CThostFtdcRspUserLoginField *pRspUserLogin, CThostFtdcRspInfoField *pRspInfo, int nRequestID,
#                                      cbool bIsLast) except -1:
#     if pRspUserLogin is NULL:
#         user_login = None
#     else:
#         user_login = ApiStructure.RspUserLoginField.from_address(<size_t> pRspUserLogin)
#
#     if pRspInfo is NULL:
#         rsp_info = None
#     else:
#         rsp_info = ApiStructure.RspInfoField.from_address(<size_t> pRspInfo)
#
#     self.OnRspUserLogin(user_login, rsp_info, nRequestID, bIsLast)


# cdef extern int MdSpi_OnRspUserLogout(self, CUserLogoutField *pUserLogout, CThostFtdcRspInfoField *pRspInfo, int nRequestID,
#                                       cbool bIsLast) except -1:
#     self.OnRspUserLogout(None if pUserLogout is NULL else ApiStruct_UserLogout(<size_t> pUserLogout),
#                          None if pRspInfo is NULL else ApiStruct_RspInfo(<size_t> pRspInfo), nRequestID, bIsLast)
#
#
# cdef extern int MdSpi_OnRspError(self, CRspInfoField *pRspInfo, int nRequestID, cbool bIsLast) except -1:
#     self.OnRspError(None if pRspInfo is NULL else ApiStruct_RspInfo(<size_t> pRspInfo), nRequestID, bIsLast)
#
#
# cdef extern int MdSpi_OnRspSubMarketData(self, CSpecificInstrumentField *pSpecificInstrument, CThostFtdcRspInfoField *pRspInfo,
#                                          int nRequestID, cbool bIsLast) except -1:
#     self.OnRspSubMarketData(
#         None if pSpecificInstrument is NULL else ApiStruct_SpecificInstrument(<size_t> pSpecificInstrument),
#         None if pRspInfo is NULL else ApiStruct_RspInfo(<size_t> pRspInfo), nRequestID, bIsLast)
#
#
# cdef extern int MdSpi_OnRspUnSubMarketData(self, CSpecificInstrumentField *pSpecificInstrument, CThostFtdcRspInfoField *pRspInfo,
#                                            int nRequestID, cbool bIsLast) except -1:
#     self.OnRspUnSubMarketData(
#         None if pSpecificInstrument is NULL else ApiStruct_SpecificInstrument(<size_t> pSpecificInstrument),
#         None if pRspInfo is NULL else ApiStruct_RspInfo(<size_t> pRspInfo), nRequestID, bIsLast)
#     return 0
#
# cdef extern int MdSpi_OnRspSubForQuoteRsp(self, CSpecificInstrumentField *pSpecificInstrument, CThostFtdcRspInfoField *pRspInfo,
#                                           int nRequestID, cbool bIsLast) except -1:
#     self.OnRspSubForQuoteRsp(
#         None if pSpecificInstrument is NULL else ApiStruct_SpecificInstrument(<size_t> pSpecificInstrument),
#         None if pRspInfo is NULL else ApiStruct_RspInfo(<size_t> pRspInfo), nRequestID, bIsLast)
#     return 0
#
# cdef extern int MdSpi_OnRspUnSubForQuoteRsp(self, CSpecificInstrumentField *pSpecificInstrument,
#                                             CThostFtdcRspInfoField *pRspInfo, int nRequestID, cbool bIsLast) except -1:
#     self.OnRspUnSubForQuoteRsp(
#         None if pSpecificInstrument is NULL else ApiStruct_SpecificInstrument(<size_t> pSpecificInstrument),
#         None if pRspInfo is NULL else ApiStruct_RspInfo(<size_t> pRspInfo), nRequestID, bIsLast)
#     return 0
#
# cdef extern int MdSpi_OnRtnDepthMarketData(self, CDepthMarketDataField *pDepthMarketData) except -1:
#     self.OnRtnDepthMarketData(
#         None if pDepthMarketData is NULL else ApiStruct_DepthMarketData(<size_t> pDepthMarketData))
#     return 0
#
# cdef extern int MdSpi_OnRtnForQuoteRsp(self, CForQuoteRspField *pForQuoteRsp) except -1:
#     self.OnRtnForQuoteRsp(None if pForQuoteRsp is NULL else ApiStruct_ForQuoteRsp(<size_t> pForQuoteRsp))
#     return 0