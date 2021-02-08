#include "CCMagic.h"
#include "CCFileUtils.h"
#include "base/ZipUtils.h"
#include "external/xxtea/xxtea.h"

static std::string _key;

namespace cocos2d {
    
    bool Magic::isEnabled() {
        return !_key.empty();
    }
    
    void Magic::set(const char* key) {
        _key = key;
    }
    
    Data Magic::get(const std::string &filename){
        Data raw = FileUtils::getInstance()->getDataFromFile(filename);
        if(raw.isNull()){
            CCLOG("WARN: file not existed : %s", filename.c_str());
            return raw;
        }
        Data decode = Magic::get(raw);
        if (!decode.isNull()) {
            raw.clear();
            return decode;
        }
        return raw;
    }
    
    Data Magic::get(const Data& dataIn) {
        Data dataOut;
        
        if (dataIn.isNull())
            return dataOut;
        if (!Magic::isEnabled())
            return dataOut;
        
        // 验证加密签名
        bool signatureOk = true;
        std::string signature = "DHGAMES";
        for (ssize_t i = 0; signatureOk && i < signature.size() && i < dataIn.getSize(); ++i) {
            signatureOk = (dataIn.getBytes()[i] == signature[i]);
        }
        // 进行解密
        if (signatureOk) {
            xxtea_long outLength = 0;
            xxtea_long inLength = static_cast<xxtea_long>(dataIn.getSize() - signature.size());
            unsigned char* inBuffer = dataIn.getBytes() + signature.size();
            unsigned char* outBuffer = xxtea_decrypt(inBuffer,
                                                     inLength,
                                                     (unsigned char*)_key.c_str(),
                                                     (xxtea_long)_key.size(),
                                                     &outLength);
            dataOut.fastSet(outBuffer, outLength);
        }
        if (dataOut.isNull())
            return dataIn;
        
        // 验证压缩签名
        bool zsignOk = true;
        std::string zsign = "DHZAMES";
        for (unsigned int i = 0; zsignOk && i < zsign.size() && i < dataOut.getSize(); ++i) {
            zsignOk = (dataOut.getBytes()[i] == zsign[i]);
        }
        // 进行解压
        if (zsignOk) {
            unsigned char* outBuffer = nullptr;
            unsigned char* inBuffer = dataOut.getBytes()+zsign.size();
            ssize_t inLength = dataOut.getSize() - zsign.size();
            ssize_t outLength = ZipUtils::inflateMemory(inBuffer, inLength, &outBuffer);
            if (outLength && inLength > 0) {
                dataOut.clear();
                dataOut.fastSet(outBuffer, outLength);
            }
        }
        return dataOut;
    }
} // namespace cocos2d

