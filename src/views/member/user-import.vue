<template>
  <div class="meedu-main-body">
    <back-bar class="mb-30" title="学员批量导入"></back-bar>

    <div class="user-import-box">
      <div class="float-left d-flex mb-30">
        <div>
          <el-button :loading="loading" type="primary" @click="choiceFile">
            导入表格
          </el-button>
        </div>
        <div class="ml-30">
          <el-link type="primary" @click="download">
            下载「学员批量导入模板」
          </el-link>
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
      let url = this.$utils.getUrl() + "template/学员批量导入模板.xlsx";
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
        for (let i = 0; i < parseData.length; i++) {
          let data = parseData[i];
          data.splice(4, 0, 0);
        }
        this.loading = true;

        // 请求导入api
        this.$refs.form.reset();

        this.$api.Member.Import({ users: parseData })
          .then(() => {
            this.loading = false;
            this.$message.success("导入成功");
          })
          .catch((e) => {
            this.loading = false;
            this.$message.error(e.message, 0);
          });
      };
      reader.readAsArrayBuffer(f);
    },
    model() {
      var array = [
        [
          "手机号",
          "密码",
          "VIP",
          "VIP过期时间",
          "是否锁定（1锁定，0不锁定）",
          "标签",
        ],
      ];
      let wscols = [
        { wch: 20 },
        { wch: 20 },
        { wch: 20 },
        { wch: 20 },
        { wch: 25 },
        { wch: 20 },
      ];
      this.$utils.importExcel(array, "学员批量导入模板.xlsx", "sheet1", wscols);
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
