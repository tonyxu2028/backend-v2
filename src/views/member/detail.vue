<template>
  <div class="user-main-body" v-if="userList" v-loading="loading">
    <div class="float-left bg-white br-15 p-30">
      <back-bar class="mb-30" title="学员详情"></back-bar>
      <div class="user-info-box">
        <div class="user-base-info-box">
          <div class="user-avatar">
            <img :src="userList.avatar" width="80" height="80" />
          </div>
          <div class="user-info">
            <div class="user-nickname">{{ userList.nick_name }}</div>
            <div class="buttons">
              <el-link
                type="primary"
                class="real-profile"
                @click="updateMember(id)"
              >
                修改资料
              </el-link>
              <el-link
                type="primary"
                class="edit-profile"
                @click="
                  $router.push({
                    name: 'MemberProfile',
                    params: { userId: id },
                  })
                "
                >实名信息</el-link
              >
            </div>
          </div>
        </div>
        <div class="panel-info-box">
          <div class="panel-info-item">ID：{{ userList.id }}</div>
          <div class="panel-info-item">手机号：{{ userList.mobile }}</div>
          <div class="panel-info-item">
            最近登录时间：{{ userList.updated_at | dateFormat }}
          </div>
          <div class="panel-info-item">
            VIP： {{ userList.role ? userList.role.name : "" }}
          </div>
          <div class="panel-info-item">
            VIP到期时间：{{ userList.role_expired_at | dateFormat }}
          </div>
          <div class="panel-info-item">
            一级邀请人：{{ userList.invitor ? userList.invitor.nick_name : "" }}
            <template v-if="userList.invitor">
              <div class="item">
                (邀请关系剩余{{
                  userList.invite_user_expired_at | dateFormat
                }}天)
              </div>
            </template>
          </div>
          <div class="panel-info-item">
            邀请码：{{ userList.is_used_promo_code === 1 ? "已使用" : "—" }}
          </div>
          <div class="panel-info-item">
            推广抽成余额：{{ userList.invite_balance }}
          </div>
          <div class="panel-info-item">IP地址：{{ userList.register_ip }}</div>
          <div class="panel-info-item">
            注册区域： {{ userList.register_area }}
          </div>
          <div class="panel-info-item">
            账号状态：<template v-if="userList.is_lock === 1"
              ><span class="c-red mr-20">已冻结</span>
              <p-link
                text="解冻"
                type="primary"
                p="member.edit"
                @click="lockMember()"
              ></p-link
            ></template>
            <template v-else
              ><span class="c-green mr-20">正常</span
              ><p-link
                text="冻结"
                type="primary"
                p="member.edit"
                @click="lockMember()"
              ></p-link
            ></template>
          </div>
          <div class="panel-info-item">
            积分：<span class="mr-20">{{ userList.credit1 }}</span>
            <p-link
              text="变动"
              type="primary"
              p="member.credit1.change"
              @click="changeCredit()"
            ></p-link>
          </div>
          <div class="panel-info-item">
            用户标签：<template v-if="userList.tags">
              <el-tag class="mr-5" v-for="item in userList.tags" :key="item.id">
                {{ item.name }}
              </el-tag>
            </template>
            <p-link
              class="ml-20"
              text="修改"
              type="primary"
              p="member.tags"
              @click="changeTags()"
            ></p-link>
          </div>
          <div class="panel-info-item large">
            备注：<template v-if="userList.remark">
              {{ userList.remark.remark }}
            </template>
            <p-link
              class="ml-20"
              text="修改"
              type="primary"
              p="member.remark.update"
              @click="changeRemark()"
            ></p-link>
          </div>
        </div>
      </div>
    </div>

    <!-- 学员课程区域 -->
    <div class="float-left bg-white br-15 p-30 mt-30">
      <el-radio-group v-model="courseTabActive">
        <el-radio-button
          :label="item.key"
          v-for="item in courseTypes"
          :key="item.key"
          >{{ item.name }}</el-radio-button
        >
      </el-radio-group>

      <div class="float-left mt-30">
        <user-orders-comp
          :id="id"
          v-if="courseTabActive === 'order'"
        ></user-orders-comp>
        <user-credit1-comp
          :id="id"
          v-else-if="courseTabActive === 'credit1'"
        ></user-credit1-comp>
        <user-invite-comp
          :id="id"
          v-else-if="courseTabActive === 'invite'"
        ></user-invite-comp>
        <user-vod-watch-records-comp
          :id="id"
          v-else-if="courseTabActive === 'vod-watch-records'"
        ></user-vod-watch-records-comp>
        <user-video-watch-records-comp
          :id="id"
          v-else-if="courseTabActive === 'video-watch-records'"
        ></user-video-watch-records-comp>
        <user-live-watch-records-comp
          :id="id"
          v-else-if="courseTabActive === 'live'"
        ></user-live-watch-records-comp>
      </div>
    </div>
    <member-dialog
      :key="updateId"
      v-if="showAddWin"
      :text="tit"
      :id="updateId"
      @close="showAddWin = false"
      @success="successEvt"
    ></member-dialog>
    <credit-dialog
      :key="userList.id"
      v-if="showCreditWin"
      :id="userList.id"
      @close="showCreditWin = false"
      @success="successEvt"
    ></credit-dialog>
    <remark-dialog
      :key="userList.id"
      v-if="showRemarkWin"
      :id="userList.id"
      @close="showRemarkWin = false"
      @success="successEvt"
    ></remark-dialog>
    <tags-dialog
      :key="userList.id"
      v-if="showTagsWin"
      :id="userList.id"
      @close="showTagsWin = false"
      @success="successEvt"
    ></tags-dialog>
  </div>
</template>

<script>
import { mapState } from "vuex";
import UserLiveWatchRecordsComp from "./detail/live-watch-records.vue";
import UserOrdersComp from "./detail/orders.vue";
import UserCredit1Comp from "./detail/credit1.vue";
import UserInviteComp from "./detail/invite.vue";
import UserVodWatchRecordsComp from "./detail/vod-watch-records.vue";
import UserVideoWatchRecordsComp from "./detail/video-watch-records.vue";
import MemberDialog from "./components/member-dialog";
import CreditDialog from "./components/credit-dialog";
import RemarkDialog from "./components/remark-dialog";
import TagsDialog from "./components/tags-dialog";

export default {
  components: {
    UserOrdersComp,
    UserCredit1Comp,
    UserInviteComp,
    UserVodWatchRecordsComp,
    UserVideoWatchRecordsComp,
    UserLiveWatchRecordsComp,
    MemberDialog,
    CreditDialog,
    RemarkDialog,
    TagsDialog,
  },
  data() {
    return {
      id: null,
      userList: null,
      loading: false,
      courseTabActive: "order",
      showAddWin: false,
      tit: null,
      updateId: null,
      showCreditWin: false,
      showRemarkWin: false,
      showTagsWin: false,
    };
  },
  computed: {
    ...mapState(["enabledAddons", "user"]),
    courseTypes() {
      let types = [
        {
          name: "订单明细",
          key: "order",
        },
      ];
      if (this.checkPermission("v2.member.courses")) {
        types.push({
          name: "录播课学习",
          key: "vod-watch-records",
        });
      }
      if (this.enabledAddons["Zhibo"]) {
        types.push({
          name: "直播课学习",
          key: "live",
        });
      }
      // if (this.enabledAddons["MeeduBooks"]) {
      //   types.push({
      //     name: "电子书",
      //     key: "books",
      //   });
      // }
      // if (this.enabledAddons["MeeduTopics"]) {
      //   types.push({
      //     name: "图文",
      //     key: "topics",
      //   });
      // }
      if (this.checkPermission("v2.member.videos")) {
        types.push({
          name: "单独订阅课时",
          key: "video-watch-records",
        });
      }
      types.push(
        ...[
          {
            name: "邀请明细",
            key: "invite",
          },
          {
            name: "积分明细",
            key: "credit1",
          },
        ]
      );

      return types;
    },
  },
  mounted() {
    this.id = this.$route.params.userId;

    this.getUser();
  },
  methods: {
    checkPermission(val) {
      return typeof this.user.permissions[val] !== "undefined";
    },
    updateMember(id) {
      this.tit = "编辑学员资料";
      this.updateId = id;
      this.showAddWin = true;
    },
    successEvt() {
      this.showAddWin = false;
      this.showCreditWin = false;
      this.showRemarkWin = false;
      this.showTagsWin = false;
      this.getUser();
    },
    changeCredit() {
      this.showCreditWin = true;
    },
    changeRemark() {
      this.showRemarkWin = true;
    },
    changeTags() {
      this.showTagsWin = true;
    },
    getUser() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      this.$api.Member.Detail(this.id).then((res) => {
        this.userList = res.data.data;
        this.loading = false;
      });
    },
    lockMember() {
      let text = "冻结后此账号将无法登录，确认冻结？";
      let value = 1;
      if (this.userList.is_lock === 1) {
        text = "解冻后此账号将正常登录，确认解冻？";
        value = 0;
      }
      this.$confirm(text, "警告", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning",
      })
        .then(() => {
          this.$api.Member.EditMulti({
            user_ids: [this.userList.id],
            field: "is_lock",
            value: value,
          })
            .then((res) => {
              this.$message.success(this.$t("common.success"));
              this.getUser();
            })
            .catch((e) => {
              this.$message.error(e.message);
            });
        })
        .catch(() => {});
    },
  },
};
</script>

<style lang="less" scoped>
.user-main-body {
  width: 100%;
  height: auto;
  float: left;
}

.user-info-box {
  width: 100%;
  height: auto;
  float: left;
  box-sizing: border-box;
  display: flex;
  justify-content: center;
  margin-top: 10px;
  flex-direction: column;

  .user-base-info-box {
    width: 100%;
    height: auto;
    float: left;
    box-sizing: border-box;
    padding-bottom: 20px;
    border-bottom: 1px solid #f3f6f9;
    display: flex;
    flex-direction: row;

    .user-avatar {
      width: 80px;
      height: 80px;
      float: left;
      margin-right: 20px;
      img {
        width: 80px;
        height: 80px;
        border-radius: 50%;
      }
    }
    .user-info {
      width: auto;
      height: 80px;
      float: left;
      display: flex;
      flex-direction: column;
      .user-nickname {
        width: auto;
        height: 20px;
        float: left;
        font-size: 20px;
        font-weight: 600;
        color: #333333;
        line-height: 20px;
        margin-top: 13px;
      }
      .buttons {
        width: auto;
        height: 14px;
        float: left;
        display: flex;
        flex-direction: row;
        margin-top: 20px;
        .real-profile {
          margin-right: 20px;
        }
        .edit-profile {
          margin-right: 20px;
        }
      }
    }
  }
  .panel-info-box {
    width: 100%;
    height: auto;
    float: left;
    box-sizing: border-box;
    padding-bottom: 20px;
    padding-top: 0px;

    display: flex;
    flex-wrap: wrap;
    .panel-info-item {
      display: flex;
      width: 325px;
      height: auto;
      font-size: 14px;
      font-weight: 400;
      color: #333333;
      line-height: 14px;
      align-items: center;
      margin-top: 30px;
      &.large {
        width: 650px;
      }
      .item {
        flex: 1;
        line-height: 20px;
        margin-left: 5px;
      }
      span {
        display: inline-block;
      }
    }
  }
}

.user-extra-info-box {
  width: 100%;
  height: auto;
  float: left;
  box-sizing: border-box;
  padding: 30px;

  .info-label {
    font-weight: bold;
    color: #333;
    margin-right: 15px;
  }

  .info-value {
    color: rgba(0, 0, 0, 0.8);
  }
}
</style>
