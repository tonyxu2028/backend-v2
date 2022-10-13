<template>
  <transition name="fade">
    <div class="paper-dialog-mask">
      <div class="paper-result-dialog-box">
        <div class="meedu-dialog-header">
          <span>成卷详情</span>
          <img
            class="icon-close"
            @click="close()"
            src="@/assets/img/close.png"
          />
        </div>
        <div class="meedu-dialog-body">
          <div class="float-left">
            <el-table
              :header-cell-style="{ background: '#f1f2f9' }"
              :data="list"
              class="float-left"
              v-loading="loading"
            >
              <el-table-column prop="id" label="试题ID" width="100">
              </el-table-column>
              <el-table-column label="关联试卷/模拟试卷/练习">
                <template slot-scope="scope">
                  <template v-if="scope.row.box.papers.length > 0">
                    <p
                      style="
                        white-space: nowrap;
                        overflow: hidden;
                        text-overflow: ellipsis;
                      "
                      v-for="item in scope.row.box.papers"
                      :key="item.id"
                    >
                      试卷-{{ item.title }}
                    </p>
                  </template>
                  <template v-if="scope.row.box.mock_papers.length > 0">
                    <p
                      style="
                        white-space: nowrap;
                        overflow: hidden;
                        text-overflow: ellipsis;
                      "
                      v-for="item in scope.row.box.mock_papers"
                      :key="item.id"
                    >
                      模拟-{{ item.title }}
                    </p>
                  </template>
                  <template v-if="scope.row.box.practices.length > 0">
                    <p
                      style="
                        white-space: nowrap;
                        overflow: hidden;
                        text-overflow: ellipsis;
                      "
                      v-for="item in scope.row.box.practices"
                      :key="item.id"
                    >
                      练习-{{ item.name }}
                    </p>
                  </template>
                </template>
              </el-table-column>
            </el-table>
          </div>
        </div>
      </div>
    </div>
  </transition>
</template>
<script>
export default {
  props: ["results"],
  data() {
    return {
      list: [],
      loading: false,
    };
  },
  mounted() {
    let params = [];
    for (let index in this.results) {
      let list = this.results[index];
      params.push({
        id: index,
        box: list,
      });
    }
    this.list = params;
  },
  methods: {
    close() {
      this.$emit("close");
    },
  },
};
</script>
