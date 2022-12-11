/*
 * Copyright 2016-present Pnoker All Rights Reserved
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *      https://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package io.github.pnoker.common.utils;

import io.github.pnoker.common.constant.common.ExceptionConstant;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileItemFactory;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.commons.CommonsMultipartFile;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;

/**
 * 文件相关的工具类集合
 *
 * @author pnoker
 * @since 2022.1.0
 */
@Slf4j
public class FileUtil {

    private FileUtil() {
        throw new IllegalStateException(ExceptionConstant.UTILITY_CLASS);
    }

    /**
     * File 转 MultipartFile
     *
     * @param fileInputStream FileInputStream
     * @return MultipartFile
     */
    public static MultipartFile fileInputStreamToMultipartFile(FileInputStream fileInputStream) {
        FileItemFactory factory = new DiskFileItemFactory(16, null);
        String textFieldName = "file";
        FileItem item = factory.createItem(textFieldName, "text/plain", true, "DC3MultipartFile");
        try {
            int length = 0;
            byte[] buffer = new byte[1024];
            OutputStream outputStream = item.getOutputStream();
            while ((length = fileInputStream.read(buffer)) > -1) {
                outputStream.write(buffer, 0, length);
            }
            outputStream.close();
            fileInputStream.close();
        } catch (IOException e) {
            log.error(e.getMessage(), e);
        }
        return new CommonsMultipartFile(item);
    }

}
