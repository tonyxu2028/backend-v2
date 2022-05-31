<template>
  <div class="meedu-main-body">
    <back-bar class="mb-30" title="试题批量导入"></back-bar>

    <div class="user-import-box">
      <div class="float-left d-flex mb-15">
        <div>
          <el-button type="primary" @click="choiceFile">
            选择Excel表格文件
          </el-button>
        </div>
        <div class="ml-30">
          <!--<el-link type="primary" @click="model()">
            点击链接下载「试题批量导入模板」
          </el-link>-->
          <a class="download-link" @click="download">
            下载「试题批量导入模板」
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
      let url = this.$utils.getUrl() + "template/试题批量导入模板.xlsx";
      window.open(url);
    },
    choiceFile() {
      this.$refs.xlsfile.click();
    },
    handleFile(e) {
      // 处理文件
      let files = e.target.files;
      if (files.length === 0) {
        return;
      }
      let f = files[0];
      // 文件扩展名检测
      let extension = f.name.split(".");
      extension = extension[extension.length - 1];
      if (!(extension === "xls" || extension === "xlsx")) {
        this.$message.error("请选择xls文件,xlsx文件");
        return;
      }
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

        // 请求导入api
        this.$refs.form.reset();
        this.$api.Exam.Question.Import({ line: 3, data: parseData })
          .then(() => {
            this.loading = false;
            this.$message.success("导入成功");
            this.$router.back();
          })
          .catch((e) => {
            this.loading = false;
            this.$message({
              showClose: true,
              message: e.message,
              type: "error",
              duration: 0,
            });
          });
      };
      reader.readAsArrayBuffer(f);
    },
    model() {
      var array = [
        [
          "分类",
          "类型",
          "难度",
          "问题",
          "答案",
          "解析",
          "分数",
          "选项1",
          "选项2",
          "选项3",
          "选项4",
          "选项5",
          "选项6",
          "选项7",
          "选项8",
          "选项9",
          "选项10",
        ],
      ];
      let wscols = [
        { wch: 20 },
        { wch: 20 },
        { wch: 15 },
        { wch: 20 },
        { wch: 20 },
        { wch: 20 },
        { wch: 10 },
        { wch: 15 },
        { wch: 15 },
        { wch: 15 },
        { wch: 15 },
        { wch: 15 },
        { wch: 15 },
        { wch: 15 },
        { wch: 15 },
        { wch: 15 },
        { wch: 15 },
      ];
      this.$utils.importExcel(array, "试题批量导入模板.xlsx", "sheet1", wscols);
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
