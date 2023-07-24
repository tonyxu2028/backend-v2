<template>
  <div class="meedu-main-body">
    <back-bar class="mb-30" title="课时批量导入"></back-bar>

    <div class="user-import-box">
      <div class="float-left d-flex mb-15">
        <div>
          <el-button type="primary" @click="choiceFile"> 导入表格 </el-button>
        </div>
        <div class="ml-30">
          <!--<el-link type="primary" @click="model()">
            下载「课时批量导入模板」
          </el-link>-->
          <a class="download-link" @click="download">
            下载「课时批量导入模板」
          </a>
        </div>
      </div>
      <div class="float-left">
        <div style="display: none">
          <form ref="form">
            <input type="file" ref="xlsfile" />
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import XLSX from "xlsx";

export default {
  data() {
    return {
      loading: false,
    };
  },
  mounted() {
    this.$nextTick(() => {
      this.$refs.xlsfile.addEventListener("change", this.handleFile, false);
    });
  },
  methods: {
    download() {
      let url = this.$utils.getUrl() + "template/课时批量导入模板.xlsx";
      window.open(url);
    },
    choiceFile() {
      this.$refs.xlsfile.click();
    },
    handleFile(e) {
      // 处理文件
      let files = e.target.files;
      if (files.length === 0) {
        this.$message.error("请选择文件");
        return;
      }
      let f = files[0];
      // 文件扩展名检测
      let extension = f.name.split(".");
      extension = extension[extension.length - 1];
      if (extension !== "xlsx") {
        this.$message.error("请选择xlsx文件");
        return;
      }

      // 读取数据
      let reader = new FileReader();
      reader.onload = (e) => {
        let data = new Uint8Array(e.target.result);
        let workbook = XLSX.read(data, { type: "array", cellDates: true });
        let parseData = this.parseData(workbook);
        parseData.splice(0, 2);
        if (parseData.length === 0) {
          this.$message.error("数据为空");
          return;
        }
        this.loading = true;
        let arr = [];
        for (let i = 0; i < parseData.length; i++) {
          let item = parseData[i];
          let tmpItem = [];
          tmpItem[0] = item[0]; //课程名
          tmpItem[1] = item[1]; //章节名
          tmpItem[2] = item[2]; //视频名
          tmpItem[3] = parseInt(item[3] || 0); //视频时长
          tmpItem[4] = item[4]; //腾讯云视频id
          tmpItem[5] = item[5]; //URL直链
          tmpItem[6] = item[6]; //阿里云视频id
          tmpItem[7] = 0; //价格[已废弃字段,但是位置保留]
          tmpItem[8] = item[7] || ""; //上架时间
          tmpItem[9] = ""; //seo关键字
          tmpItem[10] = ""; //seo描述
          tmpItem[11] = parseInt(item[8] || 0); //试看秒数
          arr.push(tmpItem);
        }
        this.$refs.form.reset();
        this.storeBatchTableCertData(arr);
      };
      reader.readAsArrayBuffer(f);
    },
    storeBatchTableCertData(data) {
      // 请求导入api
      for (let i = 0; i < data.length; i++) {
        let tempItem = data[i];
        if (!tempItem[0]) {
          this.loading = false;
          this.$message.error(`第${i + 2}行课程名为空`);
          return;
        }
        if (!tempItem[2]) {
          this.loading = false;
          this.$message.error(`第${i + 2}行课时名称为空`);
          return;
        }
        if (tempItem[3] <= 0) {
          this.loading = false;
          this.$message.error(`第${i + 2}行课时时长必须大于0`);
          return;
        }
        if (!tempItem[4] && !tempItem[5] && !tempItem[6]) {
          this.loading = false;
          this.$message.error(
            `第${i + 2}行的腾讯云视频ID、阿里云视频ID、视频URL必须填写一个`
          );
          return;
        }
      }

      this.$api.Course.Vod.Videos.ImportAct({ line: 3, data: data })
        .then(() => {
          this.loading = false;
          this.$message.success("导入成功");
        })
        .catch((e) => {
          this.loading = false;
          this.$message.error(e.message, 0);
        });
    },
    model() {
      var array = [
        [
          "所属课程名称",
          "章节名称(选填)",
          "课时名称",
          "课时时长(秒)",
          "腾讯云视频ID",
          "视频url",
          "阿里云视频ID",
          "课时价格（元）",
          "上架时间",
          "seo关键字(已下架)",
          "seo描述(已下架)",
          "试看(秒)选填",
        ],
      ];
      let wscols = [
        { wch: 20 },
        { wch: 20 },
        { wch: 20 },
        { wch: 15 },
        { wch: 20 },
        { wch: 20 },
        { wch: 20 },
        { wch: 15 },
        { wch: 20 },
        { wch: 20 },
        { wch: 20 },
        { wch: 15 },
      ];
      this.$utils.importExcel(array, "课时批量导入模板.xlsx", "sheet1", wscols);
    },
    parseData(workbook) {
      let data = [];
      workbook.SheetNames.forEach(function (sheetName) {
        var roa = XLSX.utils.sheet_to_json(workbook.Sheets[sheetName], {
          header: 1,
        });
        if (roa.length) {
          data.push(...roa);
        }
      });
      return data;
    },
  },
};
</script>

<style lang="less" scoped>
.user-import-box {
  width: 100%;
  height: auto;
  float: left;
  box-sizing: border-box;
  padding: 30px 100px;
  border-radius: 15px;
  background-color: white;
}
</style>
